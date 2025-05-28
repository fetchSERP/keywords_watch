class Ai::Seo::OptimizedPageService < BaseService
  def call(keyword)
    top_pages = fetch_top_competitor_pages(keyword.name)

    seo_page = Ai::Openai::ChatGptService.new.call(
      user_prompt: build_user_prompt(keyword, top_pages),
      system_prompt: system_prompt(keyword, top_pages),
      response_schema: response_schema(keyword)
    )

    seo_page
  end

  private

  def fetch_top_competitor_pages(keyword)
    search_results = get_search_results(keyword)
  
    threads = search_results.first(5).filter_map do |result|
      url = result[:url].to_s
      next if url.empty? || url == "N/A"
  
      Thread.new do
        begin
          response_body = Scraper::HttpClientService.new.call(url)
          doc = Nokogiri::HTML(response_body.force_encoding("UTF-8").scrub)
          content = doc.at("body")&.inner_text.to_s.strip
          raise "No content" unless content.present?
          {
            "ranking" => result[:ranking],
            "url" => url,
            "site_name" => result[:site_name],
            "description" => result[:description],
            "content" => content
          }
        rescue => e
          puts "Error fetching content for #{url}: #{e.message}"
        end
      end
    end
  
    threads.map(&:join)
    threads.map(&:value).compact
  end

  def get_search_results(keyword)
    results = []
    while(results.empty?)
      puts "fetching search results..."
      search_results = SearchEngine::QueryService.new(
        search_engine: "google",
        country: "us",
        pages_number: 1
      ).call(keyword)
      results = search_results[:search_results]
      sleep(1)
    end

    results
  end

  def js_extraction_script
    <<~JS
      return {
        page_title: document.title,
        meta_description: document.querySelector('meta[name="description"]')?.content,
        outline: [...document.querySelectorAll('h1, h2, h3')].map(el => el.innerText).join(', '),
        content: document.body.innerText
      }
    JS
  end

  def build_user_prompt(keyword, competitors)
    summaries = competitors.map.with_index(1) do |page, i|
      <<~SUMMARY
        Competitor #{i}:
        - Title: #{page["page_title"]}
        - Meta Description: #{page["meta_description"]}
        - Outline: #{page["outline"]}
        - URL: #{page["url"]}
        - Site Name: #{page["site_name"]}
        - Google Ranking: #{page["ranking"]}
  
        Content Preview:
        #{page["content"][0..3200]}...
      SUMMARY
    end.join("\n\n")
    avg_word_count = competitors.map { |p| p["content"].split.size }.sum / competitors.size
  
    <<~PROMPT
      You are an expert SEO strategist and conversion-focused copywriter.
  
      Your task is to create a **persuasive, SEO-optimized HTML page** that targets the #{keyword.search_intent} keyword: **"#{keyword.name}"**. The goal is to **outrank and outperform** the top #{competitors.size} search results listed below — both in search engine visibility and conversion rate.

      Background:
      Fetchserp is a platform that helps you retrieve search engine results and track domains rankings for a given keyword.
      Fetchserp provides an api with 3 endpoints :
      - /api/v1/serp to get search engine results for a given keyword (it supports google, bing, duckduckgo, yahoo.)
      - /api/v1/rankings to get domain rankings for a given keyword
      - /api/v1/serp_html to get the web page content of the search engine results
      Fetchserp pricing is $1 = 1000 tokens (google cost 3 credits, bing and duckduckgo cost 1 credit, yahoo cost 2 credits)
      Fetchserp offers 2500 credits to new users.
      credits never expire.
  
      Focus:
      - **#{keyword.search_intent} intent** (encourage signups)
      - **Conversion-focused copy** that builds trust and drives action
      - **SEO-optimized structure**, content, and keyword placement
  
      Requirements:
      - Buttons and call to actions are not allowed at the end of the page. They must be positioned in the middle of the page.
      - The page should be designed for an audience seeking information about this keyword.
      - Exceed by 25% the average competitor word count (#{avg_word_count} words).
      - Structure: Use clear, well-organized `<section>` blocks
      - Headings: Use informative subheadings but avoid `<h1>` tags
      - Keyword: Include naturally within the first 100 words and throughout (no keyword stuffing)
      - Call to action: include only one call to action in the page (in the middle not at the end).
      - Style: Persuasive, benefit-driven language with engaging CTAs
      - Tone: Friendly, professional, and motivating
      - HTML: Output valid, accessible, semantic HTML only
      - do not add a form in the page.
      - Design: Use Tailwind CSS:
        - do not create header, footer and hero section (they already exist).
        - Background: use `bg-transparent`
        - Body Text: `text-gray-300`
        - Titles & Subtitles: `text-gray-100`
        - Font Family: `font-sans`
        - buttons style: `text-center px-6 py-3 bg-black text-white border-2 border-yellow-500/30 rounded-md font-semibold transition-all duration-200 hover:border-yellow-500/60 hover:bg-yellow-500/10`
        - links style: `text-yellow-500`
        - use `max-w-6xl mx-auto` to center the page.
      - Responsiveness: Must be fully mobile-friendly
      - Add links if needed only to these urls :
        - https://fetchserp.com/#use-cases
        - https://fetchserp.com/#pricing
        - https://fetchserp.com/#features
        - https://fetchserp.com/#search-endpoint
        - https://fetchserp.com/app
        - do not add a call to action or button at the end there is already one at the end of the page. You can add cta only in the middle of the page.
      #{keyword.pillar && "- The html must include a link to https://www.fetchserp.com/#{keyword.pillar.parameterize}"}
      Strategy:
      Carefully analyze the strengths, weaknesses, and content structure of the top #{competitors.size} competitor pages below. Then create content that:
      - Addresses the same audience, but offers **more clarity, stronger CTAs, and better value**
      - Fills in content gaps or missing angles your competitors overlook
      - Enhances user experience and readability
      - Aligns more tightly with **#{keyword.search_intent} search intent**
  
      Competitor Reference Pages:
      #{summaries}
    PROMPT
  end

  def system_prompt(keyword, competitors)
    <<~PROMPT
      You are an expert in SEO content writing. Your goal is to generate an SEO-optimized, HTML-formatted page tailored to #{keyword.search_intent} search intent and to outperform the top #{competitors.size} ranking pages for the keyword. Focus on compelling structure, strong calls-to-action, keyword optimization, and UX best practices.
      Buttons and call to actions are not allowed at the end of the page. They must be positioned in the middle of the page.
    PROMPT
  end

  def response_schema(keyword)
    {
      strict: true,
      name: "SEO_Page_Generator",
      description: "Generate an SEO page optimized for #{keyword.search_intent} search intent",
      schema: {
        type: "object",
        properties: {
          meta_title: {
            type: "string",
            description: "Meta title, under 60 characters, including the keyword"
          },
          meta_description: {
            type: "string",
            description: "Meta description, under 160 characters, including the keyword"
          },
          headline: {
            type: "string",
            description: "Main headline of the page (not <h1>)"
          },
          subheading: {
            type: "string",
            description: "Supporting subtitle"
          },
          content: {
            type: "string",
            description: "The HTML content of the page, minimum 1000 words, styled with Tailwind CSS"
          }
        },
        required: %w[meta_title meta_description headline subheading content],
        additionalProperties: false
      }
    }
  end
end