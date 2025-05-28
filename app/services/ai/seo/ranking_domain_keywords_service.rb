class Ai::Seo::RankingDomainKeywordsService < BaseService
  def initialize(keywords_nb = 5)
    @keywords_nb = keywords_nb
  end

  def call(page_content)
    keywords = Ai::Openai::ChatGptService.new.call(
      user_prompt: user_prompt(page_content),
      system_prompt: system_prompt,
      response_schema: response_schema
    )
    keywords["keywords"]
  end

  def response_schema
    {
      "strict": true,
      "name": "SEO_keywords_generator",
      "description": "Generate #{@keywords_nb} SEO keywords for the given page content.",
      "schema": {
        "type": "object",
        "properties": {
          "keywords": {
            "type": "array",
            "description": "A list of #{@keywords_nb} SEO keywords relevant to the given page content.",
            "items": {
              "type": "string"
            }
          }
        },
        "required": ["keywords"],
        "additionalProperties": false
      }
    }
  end

  def user_prompt(page_content)
    <<~PROMPT
      Analyze the following web page content and generate #{@keywords_nb} long-tail SEO keyword phrases (5 to 6 words) that are:
  
      - Closely related to the actual content.
      - Frequently searched by users on Google.
      - Specific enough that the given content could realistically be indexed and appear in search results for them.
      - Likely to return relevant results if searched on Google today.
  
      These keywords should match real-world search queries where this page could have a chance to rank.
  
      Content:
      #{page_content}
    PROMPT
  end

  def system_prompt
    <<~PROMPT
      You are an SEO expert specializing in long-tail keyword discovery for organic traffic growth.
  
      Your task is to extract #{@keywords_nb} real-world, long-tail keyword phrases (5 to 6 words each) from a page’s content. These phrases should:
  
      - Be likely used by real people in Google search.
      - Be closely tied to the content’s actual themes and language.
      - Be realistic and specific enough that the page could appear in Google’s index for them.
      - Not be too generic or highly competitive — favor more niche or intent-driven queries.
  
      Avoid broad one- or two-word keywords. Instead, focus on longer search phrases where the page has a fair chance of being indexed and ranking.
  
      Example:
      - “email marketing strategies for freelancers”
      - “how to write a sales landing page”
      - “best seo tips for local websites”
    PROMPT
  end
end