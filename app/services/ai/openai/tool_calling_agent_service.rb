class Ai::Openai::ToolCallingAgentService < BaseService
  POLL_INTERVAL = 2

  def initialize(user_id, user_prompt)
    @user   = User.find(user_id)
    @prompt = user_prompt
  end

  def call
    Rails.logger.info "[TOOL_AGENT] Sending initial prompt via responses.create..."
    broadcast_status("🤖 Prompt sent. Waiting for LLM to decide whether to call the FetchSERP tool or reply directly…")
    resp = client.responses.create(
      model: "gpt-4.1",
      tools: [OpenaiMcp.mcp_tool(@user.fetchserp_api_key)],
      input: build_input_messages
    ).deep_to_h.deep_symbolize_keys

    resp_id = resp[:id]

    require "set"
    seen_tool_calls = Set.new

    # Poll for completion and tool outputs
    loop do
      break unless resp_id

      begin
        resp = client.responses.retrieve(resp_id).deep_to_h.deep_symbolize_keys
      rescue OpenAI::Errors::BadRequestError => e
        Rails.logger.warn "[TOOL_AGENT] Suppressed OpenAI::Errors::BadRequestError: #{e.message} — retrying after #{POLL_INTERVAL}s"
        sleep POLL_INTERVAL
        next
      end

      Rails.logger.info "[TOOL_AGENT] Polled response: #{resp.inspect}"

      # Approval request flow for MCP tool (rare, but required if your MCP asks for approval)
      if (approval = find_output(resp, :mcp_approval_request))
        Rails.logger.info "[TOOL_AGENT] Approval requested: #{approval[:id]}"
        broadcast_status("🔒 Tool approval requested by OpenAI (ID: #{approval[:id]}). Auto-approving…")
        resp = approve_tool(approval[:id], resp[:id]).deep_symbolize_keys
        broadcast_status("✅ Approval submitted. Waiting for tool execution…")
        resp_id = resp[:id]
        next
      end

      # Announce each tool call exactly once when first detected
      if (pending_call = find_output(resp, :mcp_call))
        unless seen_tool_calls.include?(pending_call[:id])
          tool_name = pending_call[:name] || pending_call[:tool_name] || pending_call[:tool] || pending_call.dig(:input, :tool) || "unknown"
          broadcast_status("🔧 Calling tool **#{tool_name}** via MCP…")
          seen_tool_calls.add(pending_call[:id])
        end
      end

      # MCP tool call output received
      if (call = completed_tool_call(resp))
        Rails.logger.info "[TOOL_AGENT] Tool call complete, output: #{call[:output].to_s.truncate(100)}"
        broadcast_status("📦 Tool call completed. Generating final answer…")
        clear_chunks_container
        stream_final_answer(call[:output])
        break
      end

      # Assistant final message (no tool call)
      if (message = assistant_output(resp))
        Rails.logger.info "[TOOL_AGENT] Assistant responded without tool call"
        broadcast_status("💬 Assistant responded without needing the tool. Streaming answer…")
        chunk_size   = 40
        stream_delay = 0.09

        message.chars.each_slice(chunk_size) do |slice|
          broadcast_chunk(slice.join)
          sleep(stream_delay)
        end
        broadcast_message(message)
        break
      end

      Rails.logger.info "[TOOL_AGENT] No tool call, approval, or message yet. Still waiting…"
      sleep POLL_INTERVAL
    end
  end

  # ---------- Turbo Stream helpers ----------

  def broadcast_message(message)
    chat_message = ChatMessage.create!(user_id: @user.id, body: message, author: "assistant")
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{@user.id}",
      target: "temp_message",
      partial: "app/chat_messages/message",
      locals: { message: chat_message }
    )
    broadcast_credit(@user) # Optional: Update user credits
  end

  def broadcast_chunk(chunk)
    Turbo::StreamsChannel.broadcast_append_to(
      "streaming_channel_#{@user.id}",
      target: "chunks_container",
      partial: "app/chat_messages/chunk",
      locals: { chunk: chunk }
    )
  end

  # Replace temp_message with a fresh, empty template so the next answer can be streamed into a clean container.
  def clear_chunks_container
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{@user.id}",
      target: "temp_message",
      partial: "app/chat_messages/temp_message"
    )
  end

  # ---------- Knowledge base for prompt ----------

  def knowledge_base
    chat_history + backlinks + keywords + competitors
  end

  def chat_history
    ChatMessage.where(user_id: @user.id).order(created_at: :asc).map do |msg|
      { role: msg.author, content: msg.body }
    end
  end

  def backlinks
    data = Backlink.where(user_id: @user.id).order(created_at: :asc).limit(50).each_with_index.map do |b, i|
      "Backlink #{i + 1}: domain: #{b.domain.name}, source_url: #{b.source_url}, target_url: #{b.target_url}, anchor_text: #{b.anchor_text}, nofollow: #{b.nofollow}, rel_attributes: #{b.rel_attributes}, context_text: #{b.context_text}, source_domain: #{b.source_domain}, target_domain: #{b.target_domain}, page_title: #{b.page_title}, meta_description: #{b.meta_description}"
    end.join("\n")

    [{ role: "user", content: "Here are the backlinks:\n#{data}" }]
  end

  def keywords
    data = Keyword.where(user_id: @user.id, is_tracked: true).order(created_at: :asc).limit(10).each_with_index.map do |k, i|
      "Keyword #{i + 1}: #{k.name}, domain: #{k.domain.name}, rank: #{k.rankings.last&.rank}, indexed: #{k.indexed}, indexed_urls: #{k.urls.take(5).join(", ")}, avg_monthly_searches: #{k.avg_monthly_searches}, competition: #{k.competition}, competition_index: #{k.competition_index}, low_bid: #{k.low_top_of_page_bid_micros}, high_bid: #{k.high_top_of_page_bid_micros}"
    end.join("\n")

    [{ role: "user", content: "Here are the keywords:\n#{data}" }]
  end

  def competitors
    data = Competitor.where(user_id: @user.id).order(serp_appearances_count: :desc).limit(10).each_with_index.map do |c, i|
      "Competitor #{i + 1}: domain: #{c.domain.name}, competitor_domain: #{c.domain_name}, serp_appearances_count: #{c.serp_appearances_count}"
    end.join("\n")

    [{ role: "user", content: "Here are the competitors:\n#{data}" }]
  end

  def system_prompt
    <<~PROMPT
      You are an AI assistant helping the user with SEO tasks. Use the provided context (chat, backlinks, keywords, competitors).
      Use tools only when necessary and explain their outputs clearly.
    PROMPT
  end

  private

  def client
    @client ||= OpenAI::Client.new(api_key: Rails.application.credentials.openai_api_key)
  end

  def build_input_messages
    [
      { role: "system", content: system_prompt.strip }
    ] + knowledge_base + [
      { role: "user", content: @prompt.strip }
    ]
  end

  # --- MCP approval flow ---
  def approve_tool(approval_id, previous_id)
    resp = client.responses.create(
      model: "gpt-4.1",
      tools: [OpenaiMcp.mcp_tool(@user.fetchserp_api_key)],
      previous_response_id: previous_id,
      input: [
        {
          type: :mcp_approval_response,
          approval_request_id: approval_id,
          approve: true
        }
      ]
    )

    resp.deep_to_h # convert the OpenAI::Internal::Type::BaseModel into a Hash with symbol keys
  end

  def completed_tool_call(resp)
    (resp[:output] || []).find { |o| o[:type] == :mcp_call && o[:output].present? }
  end

  def find_output(resp, type)
    (resp[:output] || []).find { |o| o[:type] == type }
  end

  def assistant_output(resp)
    message = (resp[:output] || []).find { |o| o[:type] == :message }
    message&.dig(:content, 0, :text)
  end

  def stream_final_answer(output_json)
    Rails.logger.info "[TOOL_AGENT] Streaming final answer from LLM..."

    # Buffer to accumulate the streamed text for persistence after streaming is done
    full_answer = ""

    stream = client.chat.completions.stream_raw(
      model: "gpt-4.1",
      messages: [
        # Include the system prompt, knowledge base context, and original user prompt
        { role: "system", content: system_prompt.strip },
        *knowledge_base,
        { role: "user", content: @prompt.strip },
        # Provide the tool output as additional context
        { role: "system", content: "Here is relevant data fetched from the SERP API:\n\n#{output_json}" }
      ]
    )

    stream.each do |chunk|
      # `chunk` is an OpenAI::Models::Chat::ChatCompletionChunk object – not a Hash.
      # Extract the delta content safely, supporting both object and Hash forms.
      delta = if chunk.respond_to?(:choices)
        # Official SDK object form
        chunk.choices&.first&.delta&.content
      else
        # Fallback for hash-like chunks (shouldn't happen with current SDK but kept for safety)
        chunk.dig("choices", 0, "delta", "content") || chunk.dig(:choices, 0, :delta, :content)
      end

      next if delta.blank?

      full_answer << delta
      broadcast_chunk(delta)
      sleep 0.09
    end

    broadcast_message(full_answer)
    broadcast_credit(@user)
  end

  def broadcast_credit(user)
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{user.id}",
      target: "user_credit",
      partial: "shared/user_credit",
      locals: { user: user }
    )
  end

  # Send plain-text status updates into the same streaming container
  def broadcast_status(text)
    broadcast_chunk("\n#{text}\n")
  end
end
