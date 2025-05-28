class Social::Linkedin::PostGeneratorService < BaseService
  def initialize(topic)
    @topic = topic
  end

  def call
    response = Ai::Openai::ChatGptService.new.call(
      user_prompt: user_prompt,
      system_prompt: system_prompt,
      response_schema: response_schema
    )
    response["post"]
  end

  private
  def user_prompt
    <<-TXT
      Generate a professional post about the following topic (max 1300 characters). Make it informative, engaging, and concise.
      - Highlight key features such as pricing, speed, and unique selling points (e.g., "fast", "affordable", "API integration", "free credits").
      - Include relevant emojis to draw attention to key points.
      - Add a clear and actionable call to action, encouraging engagement (e.g., "Let's connect," "Contact us for a demo").
      - Include the following link to my app: https://www.fetchserp.com
      - Use one relevant business or industry hashtag (e.g., #WebScraping, #DataInsights) or create a custom hashtag that fits the context.
      Topic: #{@topic}
    TXT
  end

  def system_prompt
    <<-TXT
      You are a marketing assistant specializing in creating professional LinkedIn posts. Your goal is to create engaging, concise, and informative posts that highlight the key features, benefits, and unique selling points of a product. Your tone should be professional, approachable, and friendly. Focus on providing value to a business-oriented audience, ensuring that every post includes an actionable link and relevant, industry-specific hashtags. Aim to encourage discussion, connection, and further interaction with the product.
    TXT
  end

  def response_schema
    {
      "strict": true,
      "name": "post_Generator",
      "description": "Generate a post",
      "schema": {
        "type": "object",
        "properties": {
          "post": {
            "type": "string",
            "description": "post content"
          }
        },
        "additionalProperties": false,
        "required": [ "post" ]
      }
    }
  end
end
