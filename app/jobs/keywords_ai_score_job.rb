class KeywordsAiScoreJob < ApplicationJob
  queue_as :default

  def perform(domain:)
    web_pages = domain.web_pages.sample(10).map do |web_page|
      <<~STR
        URL: #{web_page.url}
        Title: #{web_page.title}
        Meta Description: #{web_page.meta_description}
      STR
    end.join("\n")

    allowed_keywords = domain.keywords.map(&:name)

    ai_response = Ai::Openai::ChatGptService.new(model: "gpt-4o").call(
      user_prompt: user_prompt(web_pages, allowed_keywords),
      system_prompt: system_prompt(allowed_keywords),
      response_schema: response_schema(allowed_keywords)
    )

    ai_response["keywords"].each do |keyword_data|
      keyword = domain.keywords.find_by(name: keyword_data["name"])
      next unless keyword

      ActiveRecord::Base.transaction do
        keyword.update!(ai_score: keyword_data["score"])
      end
      Turbo::StreamsChannel.broadcast_replace_to(
        "streaming_channel_#{domain.user_id}",
        target: "keyword_#{keyword.id}",
        partial: "app/keywords/keyword",
        locals: { keyword: keyword }
      )
    end
    domain.with_lock do
      domain.update!(analysis_status: domain.analysis_status.merge("fetch_ai_score" => true))
    end
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{domain.user_id}",
      target: "domain_analysis_status",
      partial: "app/domains/domain_analysis_status",
      locals: { domain: domain }
    )
    KeywordsTrackerJob.perform_later(domain: domain)
  end

  def user_prompt(web_pages, allowed_keywords)
    <<~PROMPT
      Based on the following web pages:
    
      #{web_pages}
    
      And the following keywords:
      #{allowed_keywords}
    
      Score each keyword (no others!) from 0 to 100 and return them sorted by score descending.
    
      Use this exact list. Do not invent, replace, or remove any keyword.

      Return each keyword exactly once from the provided list.
      Do not duplicate or omit any keywords.
      Output exactly #{allowed_keywords.size} unique keywords, sorted by score.
      Make sure to return exactly #{allowed_keywords.size} unique keywords.
    PROMPT
  end

  def system_prompt(allowed_keywords)
    <<~PROMPT
      You are a keyword scoring assistant for SEO.
  
      You will receive:
      - A list of web pages for a specific domain.
      - A list of allowed keywords.
  
      Your task:
      - Score each keyword from 0 to 100 based on its SEO relevance and potential.
      - Use only the provided keywords — do not invent or substitute any others.
      - Return all original keywords, with no additions, deletions, or modifications.
      - Sort the result by score descending.
      - Return each keyword exactly once from the provided list.
      - Do not duplicate or omit any keywords.
      - Output exactly #{allowed_keywords.size} unique keywords, sorted by score.
  
      Important:
      - The keyword names must exactly match those provided.
      - If a keyword seems irrelevant, score it lower — do not replace it.
    PROMPT
  end

  def response_schema(allowed_keywords)
    {
      "strict": true,
      "name": "SEO_Keyword_Scorer",
      "description": "Score and sort the keywords by SEO potential",
      "schema": {
        "type": "object",
        "properties": {
          "keywords": {
            "type": "array",
            "description": "All provided keywords with a score from 0 to 100",
            "items": {
              "type": "object",
              "properties": {
                "name": {
                  "type": "string",
                  "enum": allowed_keywords
                },
                "score": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 100
                }
              },
              "required": ["name", "score"],
              "additionalProperties": false
            },
            "minItems": allowed_keywords.size,
            "maxItems": allowed_keywords.size
          }
        },
        "required": ["keywords"],
        "additionalProperties": false
      }
    }
  end
end