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
        messages: [{ role: "user", content: @user_prompt }],
        tools: tools.map(&:schema)
      }
    )

    message = response.dig("choices", 0, "message")
    tool_call = message.dig("tool_calls", 0)

    if tool_call
      tool_name = tool_call.dig("function", "name")
      args = JSON.parse(tool_call.dig("function", "arguments"))

      tool = tools.find { |t| t.schema[:function][:name] == tool_name }
      tool_result = tool.call(args)

      response = ""
      client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { role: "system", content: system_prompt },
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
          end
        }
      )
      # binding.pry
      chat_message = ChatMessage.create(user_id: @user_id, body: response, author: "AI")
      Turbo::StreamsChannel.broadcast_replace_to(
        "streaming_channel_#{@user_id}",
        target: "temp_message",
        partial: "app/chat_messages/message",
        locals: { message: chat_message }
      )
      # followup.dig("choices", 0, "message", "content")
    else
      # message["content"]
      broadcast_chunk(message["content"])
    end
  end

  def broadcast_chunk(chunk)
    Turbo::StreamsChannel.broadcast_prepend_to(
      "streaming_channel_#{@user_id}",
      target: "chunks_container",
      partial: "app/chat_messages/chunk",
      locals: { chunk: chunk }
    )
  end

  def system_prompt
    <<~PROMPT
      You are an AI assistant with access to the FetchSERP API, which provides tools for retrieving search engine results, analyzing keywords, scraping web content, and conducting SEO audits. Your role is to interpret the user's request, select the most appropriate FetchSERP tool, and provide a response based on the tool's output. Below is a list of available tools and their descriptions:

      1. **search_engine_results**: Retrieves structured search engine results for a query (e.g., site name, URL, title, description, ranking). Parameters: query (required), search_engine (default: "google"), country (default: "us"), pages_number (1-30, default: 1).
      2. **search_engine_results_html**: Retrieves raw HTML content of search engine results pages. Parameters: query (required), search_engine (default: "google"), country (default: "us"), pages_number (1-30, default: 1).
      3. **serp_text**: Retrieves text content extracted from search engine results pages. Parameters: query (required), search_engine (default: "google"), country (default: "us"), pages_number (1-30, default: 1).
      4. **domain_ranking**: Gets the ranking of a domain for a specific keyword. Parameters: keyword (required), domain (required), search_engine (default: "google"), country (default: "us"), pages_number (1-30, default: 10).
      5. **scrape_web_page**: Scrapes a web page without JavaScript. Parameters: url (required).
      6. **scrape_domain**: Scrapes multiple pages from a domain. Parameters: domain (required), max_pages (up to 200, default: 10).
      7. **scrape_web_page_with_js**: Scrapes a web page with custom JavaScript execution. Parameters: url (required), js_script (optional).
      8. **keywords_search_volume**: Gets search volume data for a list of keywords. Parameters: keywords (required, array), country (default: "us").
      9. **keywords_suggestions**: Generates keyword suggestions based on a URL or keywords. Parameters: url (optional), keywords (optional, array), country (default: "us").
      10. **backlinks**: Retrieves backlinks for a domain. Parameters: domain (required), search_engine (default: "google"), country (default: "us"), pages_number (1-30, default: 15).
      11. **domain_emails**: Retrieves email addresses from a domain. Parameters: domain (required), search_engine (default: "google"), country (default: "us"), pages_number (1-30, default: 1).
      12. **web_page_ai_analysis**: Analyzes a web page using AI with a provided prompt. Parameters: url (required), prompt (required).
      13. **web_page_seo_analysis**: Performs SEO analysis for a web page. Parameters: url (required).

      **Instructions**:
      - Analyze the user's prompt to determine their intent.
      - Select the most relevant FetchSERP tool based on the request.
      - Use the tool's parameters to structure the request, including required and optional parameters as needed.
      - If the user’s request is ambiguous, ask for clarification or suggest the most likely tool.
      - Provide a concise response summarizing the tool's output, ensuring it is relevant to the user’s request.
      - If no tool is applicable, respond with a helpful message explaining why and suggest alternatives.
      - If a tool expects a url, make sure to include the full url with the http:// or https:// prefix.
    PROMPT
  end

  private

  def client
    OpenAI::Client.new(access_token: Rails.application.credentials.openai_api_key, uri_base: "https://api.openai.com/v1")
  end
end