class Scraper::ProxyFetcherService < BaseService
  def initialize(country:, user_agent: "Lynx/2.8.8rel.2 libwww-FM/2.14 SSL-MM/1.4.1")
    @country = country
    @user_agent = user_agent
    @proxy_credentials = generate_proxy_credentials
  end

  def call(search_url)
    url = URI(search_url)
  
    http = Net::HTTP.new(url.host, url.port, @proxy_credentials[:host], @proxy_credentials[:port], @proxy_credentials[:user], @proxy_credentials[:pass])
    http.use_ssl = (url.scheme == "https")
  
    request = Net::HTTP::Get.new(url)
    set_headers(request)
  
    response = http.request(request)
  
    max_redirects = 15
    redirects = 0
    while response.is_a?(Net::HTTPRedirection) && redirects < max_redirects
      url = URI(response['location'])
      http = Net::HTTP.new(url.host, url.port, @proxy_credentials[:host], @proxy_credentials[:port], @proxy_credentials[:user], @proxy_credentials[:pass])
      http.use_ssl = (url.scheme == "https")
      request = Net::HTTP::Get.new(url)
      set_headers(request)
      response = http.request(request)
      redirects += 1
    end
  
    if response.is_a?(Net::HTTPOK)
      response.body.force_encoding("UTF-8").scrub
    else
      raise "Failed to fetch Google search results: #{response.code} #{response.message}"
    end
  end

  def generate_proxy_credentials
    {
      host: "pr.oxylabs.io",
      port: 7777,
      user: "customer-#{Rails.application.credentials.proxy_username}-country-#{@country.upcase}-sessid-#{SecureRandom.hex(8)}",
      pass: Rails.application.credentials.proxy_password
    }
  end

  def set_headers(request)
    request['User-Agent'] = @user_agent
    request['Cookie'] = "CONSENT=YES+cb"
    request['Accept'] = '*/*'
    request['Connection'] = 'keep-alive'
  end
end