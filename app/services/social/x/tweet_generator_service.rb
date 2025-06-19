class Social::X::TweetGeneratorService < BaseService
  def initialize(topic)
    @topic = topic
  end

  def call
    response = Ai::Openai::ChatGptService.new.call(
      user_prompt: user_prompt,
      system_prompt: system_prompt,
      response_schema: response_schema
    )
    response["tweet"]
  end

  private

  def user_prompt
    <<-TXT
      Generate an engaging tweet (max 280 characters) about this topic: "#{@topic}".

      Focus on SEO tools and features from https://www.keywords.watch:
      - Real-time keyword tracking
      - AI-powered SEO insights
      - Competitor analysis
      - Technical SEO analysis
      - Backlink analysis
      - Domain analysis
      - Keyword analysis
      - Google Ads import
      - Daily ranking updates
      - 250 free credits (no card required)

      Requirements:
      - Make it catchy and benefit-driven
      - Use 1–2 relevant emojis to highlight key points
      - Include the URL https://www.keywords.watch
      - Suggest one relevant hashtag (e.g., #SEOtools, #KeywordTracking)

      Do NOT exceed the character limit. Ensure the call-to-action is clear.
    TXT
  end

  def system_prompt
    <<-TXT
      You are an expert marketing copywriter specializing in social media engagement.
      Your job is to write concise, professional tweets that highlight the core value and benefits of an SEO SaaS tool.
      Emphasize user value, clarity, and engagement.
      Your tone should be confident, helpful, and a little playful with emojis.
    TXT
  end

  def response_schema
    {
      "strict": true,
      "name": "Tweet_Generator",
      "description": "Generate a Tweet",
      "schema": {
        "type": "object",
        "properties": {
          "tweet": {
            "type": "string",
            "description": "tweet content"
          }
        },
        "additionalProperties": false,
        "required": ["tweet"]
      }
    }
  end
end
