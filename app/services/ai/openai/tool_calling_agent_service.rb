class Ai::Openai::ToolCallingAgentService < BaseService
  def initialize(user_id, user_prompt)
    @user_id = user_id
    @user_prompt = user_prompt
  end

  def call
    tools = Ai::Openai::Tools::FetchSerp.tools

    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [{ role: "system", content: system_prompt }] + knowledge_base + [{ role: "user", content: @user_prompt }],
        tools: tools.map(&:schema)
      }
    )
    
    message = response.dig("choices", 0, "message")
    tool_call = message.dig("tool_calls", 0)

    if tool_call
      tool_name = tool_call.dig("function", "name")
      args = JSON.parse(tool_call.dig("function", "arguments"))

      tool = tools.find { |t| t.schema[:function][:name] == tool_name }
      tool_result = tool.call(args.merge("user_id" => @user_id))

      response = ""
      client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "system", content: system_prompt }] + knowledge_base + [
            { role: "user", content: @user_prompt },
            { role: "assistant", tool_calls: [tool_call] },
            {
              role: "tool",
              tool_call_id: tool_call["id"],
              name: tool_name,
              content: tool_result.to_json
            }
          ],
          stream: proc do |chunk, _bytesize|
            delta = chunk.dig("choices", 0, "delta", "content")
            next unless delta
            response += delta
            broadcast_chunk(delta)
            sleep 0.05
          end
        }
      )
      broadcast_message(response)
    else
      broadcast_message(message["content"])
    end
  end

  def broadcast_message(message)
    chat_message = ChatMessage.create!(user_id: @user_id, body: message, author: "assistant")
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{@user_id}",
      target: "temp_message",
      partial: "app/chat_messages/message",
      locals: { message: chat_message }
    )
  end

  def broadcast_chunk(chunk)
    Turbo::StreamsChannel.broadcast_append_to(
      "streaming_channel_#{@user_id}",
      target: "chunks_container",
      partial: "app/chat_messages/chunk",
      locals: { chunk: chunk }
    )
  end

  def knowledge_base
    chat_history + backlinks + keywords + competitors
  end

  def chat_history
    ChatMessage.where(user_id: @user_id).order(created_at: :asc).map do |msg|
      {
        role: msg.author,
        content: msg.body
      }
    end
  end

  def backlinks
    backlinks_data = Backlink.where(user_id: @user_id).order(created_at: :asc).each_with_index.map do |backlink, index|
      "Backlink #{index + 1}: domain: #{backlink.domain.name}, source_url: #{backlink.source_url}, target_url: #{backlink.target_url}, anchor_text: #{backlink.anchor_text}, nofollow: #{backlink.nofollow}, rel_attributes: #{backlink.rel_attributes}, context_text: #{backlink.context_text}, source_domain: #{backlink.source_domain}, target_domain: #{backlink.target_domain}, page_title: #{backlink.page_title}, meta_description: #{backlink.meta_description}"
    end.join("\n")
  
    [
      {
        role: "user",
        content: "Here are the backlinks for the user:\n#{backlinks_data}"
      }
    ]
  end

  def keywords
    keywords_data = Keyword.where(user_id: @user_id).order(created_at: :asc).each_with_index.map do |keyword, index|
      "Keyword #{index + 1}: #{keyword.name}, domain: #{keyword.domain.name}, rank: #{keyword.rankings.last&.rank}, indexed: #{keyword.indexed}, indexed_urls: #{keyword.urls.join(", ")}, avg_monthly_searches: #{keyword.avg_monthly_searches}, competition: #{keyword.competition}, competition_index: #{keyword.competition_index}, low_top_of_page_bid_micros: #{keyword.low_top_of_page_bid_micros}, high_top_of_page_bid_micros: #{keyword.high_top_of_page_bid_micros}"
    end.join("\n")

    [
      {
        role: "user",
        content: "Here are the keywords for the user:\n#{keywords_data}"
      }
    ]
  end

  def competitors
    competitors_data = Competitor.where(user_id: @user_id).order(created_at: :asc).each_with_index.map do |competitor, index|
      "Competitor #{index + 1}: domain: #{competitor.domain.name}, competitor_domain: #{competitor.domain_name}, serp_appearances_count: #{competitor.serp_appearances_count}"
    end.join("\n")
    
    [
      {
        role: "user",
        content: "Here are the competitors for the user:\n#{competitors_data}"
      }
    ]
  end

  def system_prompt
    <<~PROMPT
      You are an AI assistant helping the user with SEO tasks, keyword research, backlink analysis, and content strategies. You have already received extensive contextual data, including chat history, keyword metrics, backlink details, and competitors.
  
      Your role is to:
      - First use the provided context (chat history, keywords, backlinks, competitors) to generate insightful, helpful, and actionable responses.
      - Only call tools from the FetchSERP API **if the user request cannot be answered using the given data**.
      - When using a tool, explain briefly why the tool was used and summarize its output clearly and concisely.
      - If a tool is needed, select the most relevant one based on the user’s request and tool capabilities.
      - If the user’s prompt is ambiguous, ask a clarifying question before calling a tool.
  
      **Available Tools (use only if necessary):**
      1. **search_engine_results** – Structured SERP data. Params: query (required), search_engine, country, pages_number.
      2. **search_engine_results_html** – Raw HTML of SERPs. Params: query (required), search_engine, country, pages_number.
      3. **serp_text** – Extracted text from SERPs. Params: query (required), search_engine, country, pages_number.
      4. **domain_ranking** – Domain rank for a keyword. Params: keyword (required), domain (required), search_engine, country, pages_number.
      5. **scrape_web_page** – Scrape a single page (no JS). Params: url (required).
      6. **scrape_domain** – Crawl multiple pages of a domain. Params: domain (required), max_pages.
      7. **scrape_web_page_with_js** – Scrape page with JavaScript. Params: url (required), js_script (optional).
      8. **keywords_search_volume** – Search volume for keywords. Params: keywords (required array), country.
      9. **keywords_suggestions** – Generate keyword suggestions. Params: url or keywords (array), country.
      10. **backlinks** – Retrieve backlinks. Params: domain (required), search_engine, country, pages_number.
      11. **domain_emails** – Extract emails from a domain. Params: domain (required), search_engine, country, pages_number.
      12. **web_page_ai_analysis** – AI analysis of a page. Params: url (required), prompt (required).
      13. **web_page_seo_analysis** – SEO audit. Params: url (required).
      14. **check_indexation** – Check if a page is indexed. Params: url (required).
      15. **generate_long_tail_keywords** – Generate long tail keywords. Params: url (required).

  
      **When responding:**
      - Do not summarize the tools unless the user asks.
      - Focus on interpreting data and helping the user make decisions or generate ideas.
      - Use natural, helpful language and suggest specific next steps if applicable.
    PROMPT
  end

  private

  def client
    OpenAI::Client.new(access_token: Rails.application.credentials.openai_api_key, uri_base: "https://api.openai.com/v1")
  end
end