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
      Generate a tweet about the following topic (max 280 characters). Make it engaging and concise. 
      - Include key features like pricing, speed, and unique selling points (e.g., "fast", "cheap", "API", "free credits").
      - Add relevant emojis to highlight key points.
      - Include the following link to my app: https://www.keywords.watch
      - Suggest one relevant hashtag (e.g., #WebScraping) or create a unique hashtag.
      Topic: #{@topic}
    TXT
  end

  def system_prompt
    <<-TXT
      You are a marketing assistant. Your job is to create concise, engaging, and informative tweets. You should focus on highlighting key product features, benefits, and unique selling points in a way that appeals to a professional audience. Your tone should be friendly and helpful, and you should always include an actionable link and relevant hashtags.
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
        "required": [ "tweet" ]
      }
    }
  end
end
