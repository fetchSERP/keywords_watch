class Ai::Openai::ToolCallingAgentService < BaseService
  POLL_INTERVAL = 2

  def initialize(user_id, user_prompt)
    @user   = User.find(user_id)
    @prompt = user_prompt
  end

  def call
    resp = send_initial_prompt
    Rails.logger.info "[TOOL_AGENT] Initial response: #{resp.inspect}"

    loop do
      if (approval = find_output(resp, "mcp_approval_request"))
        Rails.logger.info "[TOOL_AGENT] Approval requested: #{approval["id"]}"
        resp = approve_tool(approval["id"], resp["id"])
        next
      end

      if (call = completed_tool_call(resp))
        Rails.logger.info "[TOOL_AGENT] Tool call complete, output: #{call["output"].truncate(100)}"
        final_response = handle_tool_output_and_continue(call["output"], resp["id"])
        stream_response_chunks(final_response)
        break
      end

      if (message = assistant_output(resp))
        Rails.logger.info "[TOOL_AGENT] Assistant responded without tool call"
        broadcast_message(message)
        break
      end

      Rails.logger.info "[TOOL_AGENT] No tool call, approval, or message. Polling again."
      sleep POLL_INTERVAL
      resp = client.responses.retrieve(response_id: resp["id"])
    end
  end

  def broadcast_message(message)
    chat_message = ChatMessage.create!(user_id: @user.id, body: message, author: "assistant")
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{@user.id}",
      target: "temp_message",
      partial: "app/chat_messages/message",
      locals: { message: chat_message }
    )
  end

  def broadcast_chunk(chunk)
    Turbo::StreamsChannel.broadcast_append_to(
      "streaming_channel_#{@user.id}",
      target: "chunks_container",
      partial: "app/chat_messages/chunk",
      locals: { chunk: chunk }
    )
  end

  def stream_response_chunks(response)
    Rails.logger.info "[STREAM] Streaming chunks for response #{response["id"]}"
    client.responses.stream(response_id: response["id"]) do |chunk|
      next unless chunk["delta"]
      content = chunk["delta"]["text"]
      broadcast_chunk(content) if content.present?
    end
  end

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
    OpenaiMcp.client
  end

  def build_input
    history = knowledge_base.map { |m| "#{m[:role].capitalize}: #{m[:content]}" }.join("\n\n")
    <<~TXT
      #{system_prompt}

      #{history}

      User: #{@prompt}
    TXT
  end

  def send_initial_prompt
    client.responses.create(
      parameters: {
        model: "gpt-4.1",
        tools: [OpenaiMcp.mcp_tool(@user.fetchserp_api_key)],
        input: build_input.strip
      }
    )
  end

  def approve_tool(approval_id, previous_id)
    client.responses.create(
      parameters: {
        model: "gpt-4.1",
        tools: [OpenaiMcp.mcp_tool(@user.fetchserp_api_key)],
        previous_response_id: previous_id,
        input: [{ type: "mcp_approval_response", approval_request_id: approval_id, approve: true }]
      }
    )
  end

  def completed_tool_call(resp)
    (resp["output"] || []).find { |o| o["type"] == "mcp_call" && o["output"].present? }
  end

  def find_output(resp, type)
    (resp["output"] || []).find { |o| o["type"] == type }
  end

  def assistant_output(resp)
    message = (resp["output"] || []).find { |o| o["type"] == "message" }
    message&.dig("content", 0, "text")
  end

  def handle_tool_output_and_continue(output_json, previous_id)
    data = JSON.parse(output_json) rescue output_json
    body = data.is_a?(String) ? data : JSON.pretty_generate(data)

    Rails.logger.info "[TOOL_CALL] Received tool output: #{body.inspect}"

    broadcast_message(body)

    follow_up_messages = [ { role: "system", content: system_prompt.strip } ] +
                        knowledge_base +
                        [
                          { role: "user", content: "Tool result:\n#{body}" },
                          { role: "user", content: @prompt.strip }
                        ]

    client.responses.create(
      parameters: {
        model: "gpt-4.1",
        tools: [],
        previous_response_id: previous_id,
        input: follow_up_messages
      }
    )
  end

  def broadcast_credit(user)
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{user.id}",
      target: "user_credit",
      partial: "shared/user_credit",
      locals: { user: user }
    )
  end
end
