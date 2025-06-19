class Ai::Seo::LongTailKeywordsService < BaseService
  def initialize(seed_keyword:, count: 5)
    @seed_keyword = seed_keyword
    @count = count
  end

  def call
    Ai::Openai::ChatGptService.new.call(
      user_prompt: user_prompt(@seed_keyword.name, @count),
      system_prompt: system_prompt,
      response_schema: response_schema(@count)
    )
  end

  def response_schema(count)
    {
      "strict": true,
      "name": "SEO_keywords_generator",
      "description": "Generate #{count} long tail keywords for each of the four search intents: informational, navigational, commercial, and transactional.",
      "schema": {
        "type": "object",
        "properties": {
          "keywords_by_intent": {
            "type": "object",
            "properties": {
              "informational": {
                "type": "array",
                "items": keyword_schema,
                "minItems": count,
                "maxItems": count
              },
              "navigational": {
                "type": "array",
                "items": keyword_schema,
                "minItems": count,
                "maxItems": count
              },
              "commercial": {
                "type": "array",
                "items": keyword_schema,
                "minItems": count,
                "maxItems": count
              },
              "transactional": {
                "type": "array",
                "items": keyword_schema,
                "minItems": count,
                "maxItems": count
              }
            },
            "required": ["informational", "navigational", "commercial", "transactional"],
            "additionalProperties": false
          }
        },
        "required": ["keywords_by_intent"],
        "additionalProperties": false
      }
    }
  end

  def keyword_schema
    {
      "type": "object",
      "properties": {
        "long_tail_keyword": {
          "type": "string",
          "description": "A specific long-tail keyword"
        },
        "search_intent": {
          "type": "string",
          "enum": ["informational", "navigational", "commercial", "transactional"]
        },
        "difficulty": {
          "type": "string",
          "enum": ["low", "medium", "high"]
        },
        "search_volume": {
          "type": "string",
          "enum": ["0-100", "100-1K", "1K-10K", "10K-100K", "100K+"]
        }
      },
      "required": ["long_tail_keyword", "search_intent", "difficulty", "search_volume"],
      "additionalProperties": false
    }
  end

  def user_prompt(seed_keyword_name, count)
    <<~PROMPT
      Generate #{count} long tail keywords for: "#{seed_keyword_name}"

      Requirements:
      1. Include a mix of different search intents (informational, navigational, commercial, transactional)
      2. Consider local variations if relevant
      3. Include question-based keywords
      4. Include comparison keywords
      5. Include "how to" and "best" variations
      6. Consider seasonal variations if applicable
      7. Include price-related keywords if relevant
      8. Consider user pain points and problems
      9. Include feature-specific keywords
      10. Consider industry-specific terminology

      For each keyword, provide:
      - The long tail keyword
      - Search intent
      - Estimated difficulty
      - Estimated search volume range

      Group the results by search intent and generate exactly #{count} keywords for each intent.

      Prioritize keywords with the highest estimated search volume where possible.

      Format the response according to the provided schema.
    PROMPT
  end

  def system_prompt
    <<~PROMPT
      You are an expert SEO strategist and content writer with deep knowledge of:
      - Search engine optimization
      - Content marketing
      - User search behavior
      - Keyword research methodologies
      - Industry-specific terminology
      - Local SEO
      - E-commerce optimization
      - B2B and B2C marketing

      Your task is to generate comprehensive, well-researched long tail keywords that:
      1. Target specific user intents
      2. Have commercial potential
      3. Are relevant to the target audience
      4. Consider current market trends
      5. Account for seasonal variations
      6. Include local and regional variations
      7. Cover different stages of the buyer's journey
      8. Address common user questions and pain points
      9. Include industry-specific terminology
      10. Consider competitive landscape

      Focus on generating keywords that are:
      - Specific and targeted
      - Relevant to the main keyword
      - Have clear search intent
      - Show commercial potential
      - Are actionable for content creation
    PROMPT
  end

end