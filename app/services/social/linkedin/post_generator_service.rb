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
    <<~TXT
      Write a professional LinkedIn post (max 1300 characters) about this topic: "#{@topic}".
      Your audience: SEO professionals, digital marketers, and SaaS founders.

      Requirements:
      - Make the post informative, compelling, and concise.
      - Highlight key features of https://tracker.fetchserp.com:
        * Keyword Rank Tracking
        * Keyword Intelligence
        * Google Ads Import
        * Competitor Insights
        * Technical SEO Analysis
        * Index Coverage
        * Backlink Analysis
        * Competitor Analysis
        * AI-Powered SEO Agent with access to https://www.fetchserp.com API
        * Credit-based pricing with 2,500 free credits to start
      - Emphasize benefits like:
        * Daily ranking updates 
        * Fast & accurate data 
        * No credit card needed 
      - Include 1-2 relevant emojis per paragraph to improve readability.
      - Add a clear and actionable call to action (e.g. "Try it free", "See your rankings today", "Start your SEO journey").
      - Include this link: https://tracker.fetchserp.com
      - Include one relevant hashtag (e.g., #SEO, #KeywordTracking, or #KeywordsWatch).

      Avoid sounding overly promotional or generic — instead, show how this tool solves real SEO tracking problems.
    TXT
  end

  def system_prompt
    <<~TXT
      You are a professional content marketing assistant. Your role is to write high-performing LinkedIn posts for B2B SaaS companies. Use a confident, value-driven, and friendly tone that speaks directly to professionals in marketing, SEO, and analytics roles. Be concise and clear, and always include practical benefits, a call to action, and one relevant industry hashtag. Use light emoji emphasis to break text blocks and guide the reader's eye.
    TXT
  end

  def response_schema
    {
      strict: true,
      name: "post_Generator",
      description: "Generate a professional LinkedIn post for tracker.fetchserp.com",
      schema: {
        type: "object",
        properties: {
          post: {
            type: "string",
            description: "The complete LinkedIn post content"
          }
        },
        additionalProperties: false,
        required: ["post"]
      }
    }
  end
end
