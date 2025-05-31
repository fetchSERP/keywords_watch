class FetchSerp::ClientService < BaseService
  BASE_URL = 'https://www.fetchserp.com'

  def initialize(user:)
    @user = user
    @bearer_token = Rails.application.credentials.fetch_serp_api_key
    @http_client = Scraper::HttpClientService.new
  end

  def search_engine_results(query, search_engine = 'google', country = 'us', pages_number = 1)
    get('/api/v1/serp', query: { query: query, search_engine: search_engine, country: country, pages_number: pages_number })
  end

  def search_engine_results_html(query, search_engine = 'google', country = 'us', pages_number = 1)
    get('/api/v1/serp_html', query: { query: query, search_engine: search_engine, country: country, pages_number: pages_number })
  end

  def search_engine_results_text(query, search_engine = 'google', country = 'us', pages_number = 1)
    get('/api/v1/serp_text', query: { query: query, search_engine: search_engine, country: country, pages_number: pages_number })
  end

  def domain_ranking(keyword, domain, search_engine = 'google', country = 'us', pages_number = 10)
    get('/api/v1/ranking', query: { keyword: keyword, domain: domain, search_engine: search_engine, country: country, pages_number: pages_number })
  end

  def scrape_web_page(url)
    get('/api/v1/scrape', query: { url: url })
  end

  def scrape_domain(domain, max_pages = 10)
    get('/api/v1/scrape_domain', query: { domain: domain, max_pages: max_pages })
  end

  def scrape_web_page_with_js(url, js_script)
    post('/api/v1/scrape_js', body: { url: url, js_script: js_script })
  end

  def keywords_search_volume(keywords, country = 'us')
    get('/api/v1/keywords_search_volume', query: { keywords: keywords, country: country })
  end

  def keywords_suggestions(url: nil, keywords: nil, country: 'us')
    query = { country: country }
    query[:url] = url if url
    query[:keywords] = keywords if keywords
    get('/api/v1/keywords_suggestions', query: query)
  end

  def backlinks(domain, search_engine = 'google', country = 'us', pages_number = 20)
    get('/api/v1/backlinks', query: { domain: domain, search_engine: search_engine, country: country, pages_number: pages_number })
  end

  def domain_emails(domain, search_engine = 'google', country = 'us', pages_number = 1)
    get('/api/v1/domain_emails', query: { domain: domain, search_engine: search_engine, country: country, pages_number: pages_number })
  end

  def web_page_ai_analysis(url, prompt)
    post('/api/v1/web_page_ai_analysis', body: { url: url, prompt: prompt })
  end

  def web_page_seo_analysis(url)
    get('/api/v1/web_page_seo_analysis', query: { url: url })
  end

  def check_indexation(domain:, keyword:)
    get('/api/v1/indexation', query: { domain: domain, keyword: keyword })
  end

  def generate_long_tail_keywords(keyword:, search_intent: "informational", count: 10)
    get('/api/v1/long_tail_keywords_generator', query: { keyword: keyword, search_intent: search_intent, count: count })
  end

  private

  def headers
    { 'Authorization' => "Bearer #{@bearer_token}" }
  end

  def get(path, query: {})
    uri = URI.join(BASE_URL, path)
    uri.query = URI.encode_www_form(query)
    
    response = @http_client.get(uri.to_s, headers: headers)
    json = handle_response(response)
    CreditService.new(user: @user).call(path: path, params: query)
    json
  end

  def post(path, body: {})
    uri = URI.join(BASE_URL, path)
    response = @http_client.post(uri.to_s, body: body, headers: headers)
    json = handle_response(response)
    CreditService.new(user: @user).call(path: path, params: body)
    json
  end

  def handle_response(response)
    case response.code.to_i
    when 200
      JSON.parse(response.body)
    when 401
      raise "Unauthorized: Invalid bearer token"
    when 403
      raise "Forbidden: You lack necessary permissions"
    when 422
      raise "Validation Error: #{parse_error(response)}"
    when 500
      raise "Server Error: #{parse_error(response)}"
    else
      raise "Unexpected response: #{response.code} - #{response.body}"
    end
  end

  def parse_error(response)
    JSON.parse(response.body)['error'] rescue response.body
  end
end