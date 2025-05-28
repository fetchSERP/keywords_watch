require 'net/http'
require 'json'

class Scraper::HttpClientService < BaseService
  DEFAULT_TIMEOUT = 60
  MAX_REDIRECTS = 5

  def initialize
    @redirect_limit = MAX_REDIRECTS
  end

  def get(url, headers: {})
    perform_request(url, :get, headers: headers)
  end

  def post(url, body: nil, headers: {})
    perform_request(url, :post, body: body, headers: headers)
  end

  private

  def perform_request(url, method, body: nil, headers: {})
    raise "Too many redirects" if @redirect_limit == 0

    uri = URI.parse(url)
    http = setup_http_client(uri)
    request = build_request(uri, method, body, headers)
    response = http.request(request)

    handle_response(response, uri, method, body, headers)
  end

  def setup_http_client(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = DEFAULT_TIMEOUT
    http.read_timeout = DEFAULT_TIMEOUT
    http
  end

  def build_request(uri, method, body, headers)
    default_headers = {
      "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
      "Content-Type" => "application/json"
    }

    request = case method
    when :get
      Net::HTTP::Get.new(uri.request_uri, default_headers.merge(headers))
    when :post
      Net::HTTP::Post.new(uri.request_uri, default_headers.merge(headers))
    end

    request.body = body.to_json if body && method == :post
    request
  end

  def handle_response(response, uri, method, body, headers)
    case response
    when Net::HTTPRedirection
      handle_redirect(response, uri, method, body, headers)
    when Net::HTTPSuccess
      response
    else
      raise "HTTP error: #{response.code}"
    end
  end

  def handle_redirect(response, uri, method, body, headers)
    new_location = response["location"]
    raise "Redirect with no location header" unless new_location
    
    url = URI.join(uri, new_location).to_s
    @redirect_limit -= 1
    
    case method
    when :get
      get(url, headers: headers)
    when :post
      post(url, body: body, headers: headers)
    end
  end
end