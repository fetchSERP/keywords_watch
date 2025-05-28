class SearchEngine::Ranking::GoogleService < SearchEngine::Ranking::BaseService
  MAX_RETRIES = 5
  MAX_PAGES = 30
  RESULTS_PER_PAGE = 10
  MAX_THREADS = 15

  def initialize(country: "us", domain:, options: "{}")
    @country = country
    @domain = domain
    @options = options
  end

  # def call(query)
  #   url = URI("http://#{ENV.fetch('GOOGLE_SERP_HOST', 'localhost:3001')}/api/ranking/#{@country}?q=#{query}&domain=#{@domain}")
  #   response = Net::HTTP.get(url)
  #   JSON.parse(response)
  # end

  def call(query)
    google_service = SearchEngine::Search::GoogleService.new(country: @country)
    found_domain = []
    proxy_credentials = initialize_proxy_credentials
    mutex = Mutex.new
    errors = []

    (0...MAX_PAGES).each_slice(MAX_THREADS) do |page_batch|
      threads = []
      page_batch.each do |page_number|
        threads << Thread.new do
          retry_count = 0
          page_url = page_number == 0 ? 
            "https://www.google.com/search?q=#{CGI.escape(query)}&hl=#{@country}&ie=UTF-8&oe=UTF-8" :
            "https://www.google.com/search?q=#{CGI.escape(query)}&hl=#{@country}&start=#{page_number * RESULTS_PER_PAGE}&ie=UTF-8&oe=UTF-8"

          begin
            Rails.logger.info("Fetching page #{page_number + 1}")
            
            thread_proxy_credentials = mutex.synchronize { proxy_credentials.dup }
            
            html = google_service.fetch_with_proxy(
              search_url: page_url,
              proxy_host: thread_proxy_credentials[:host],
              proxy_port: thread_proxy_credentials[:port],
              proxy_user: thread_proxy_credentials[:user],
              proxy_pass: thread_proxy_credentials[:pass]
            )

            position_offset = page_number * RESULTS_PER_PAGE
            json = google_service.parse_google_results(html, position_offset)
            
            domain_matches = json[:search_results].select do |result|
              escaped_domain = Regexp.escape(@domain)
              regex = %r{\Ahttps?://([a-z0-9-]+\.)*#{escaped_domain}(/|$)}i
              !!(result[:url] =~ regex)
            end
            
            mutex.synchronize do
              found_domain << domain_matches
            end

          rescue => e
            retry_count += 1
            Rails.logger.error("Error fetching page #{page_number + 1} (attempt #{retry_count}/#{MAX_RETRIES}): #{e.message}")
            
            if retry_count == MAX_RETRIES
              Rails.logger.error("Max retries reached for page #{page_number + 1}")
              mutex.synchronize do
                errors << { page: page_number + 1, error: e.message }
              end
              return
            end
            
            mutex.synchronize do
              proxy_credentials = initialize_proxy_credentials
            end
            
            retry
          end
        end
      end

      threads.each(&:join)
    end

    { 
      results: found_domain.flatten.compact,
      errors: errors
    }
  end

  private

  def initialize_proxy_credentials
    {
      host: "pr.oxylabs.io",
      port: 7777,
      user: "customer-#{Rails.application.credentials.proxy_username}-country-#{@country.upcase}-sessid-#{SecureRandom.hex(8)}",
      pass: Rails.application.credentials.proxy_password
    }
  end
end
