class Scraper::DomainService < BaseService
  SITEMAP_PATHS = [
    '/sitemap.xml',
    '/sitemap.xml.gz',
    '/sitemap_index.xml',
    '/sitemap_index.xml.gz',
    '/sitemap/sitemap.xml',
    '/sitemap/sitemap.xml.gz',
    '/sitemap/sitemap_index.xml',
    '/sitemap/sitemap_index.xml.gz'
  ].freeze

  BATCH_SIZE = 10
  DEFAULT_MAX_PAGES = 10

  def initialize(domain:, max_pages: DEFAULT_MAX_PAGES)
    @domain = domain
    @max_pages = max_pages.to_i
    @http_client = Scraper::HttpClientService.new
  end

  def call
    sitemap_results = fetch_sitemap_urls
    {
      results: sitemap_results.any? ? sitemap_results : fetch_main_page_urls
    }
  end

  private

  def fetch_sitemap_urls
    sitemap_doc = find_sitemap_doc
    return [] unless sitemap_doc

    urls = extract_sitemap_urls(sitemap_doc)
    fetch_urls_in_parallel(urls)
  rescue StandardError => e
    Rails.logger.error("Error fetching sitemap: #{e.message}")
    []
  end

  def fetch_main_page_urls
    response = @http_client.get("https://#{@domain}")
    return [] unless response

    doc = Nokogiri::HTML(response.force_encoding("UTF-8").scrub)
    urls = extract_links(doc)
    fetch_urls_in_parallel(urls)
  rescue StandardError => e
    Rails.logger.error("Error fetching main page: #{e.message}")
    []
  end

  def fetch_urls_in_parallel(urls)
    urls = urls.first(@max_pages) if @max_pages
    results = []
    mutex = Mutex.new

    urls.each_slice(BATCH_SIZE) do |url_batch|
      threads = url_batch.map do |url|
        Thread.new do
          fetch_url_with_error_handling(url, mutex, results)
        end
      end
      threads.each(&:join)
    end

    results
  end

  def find_sitemap_doc
    SITEMAP_PATHS.each do |path|
      doc = fetch_and_parse_sitemap(path)
      return doc if doc
    end
    nil
  end

  def fetch_and_parse_sitemap(path)
    url = "https://#{@domain}#{path}"
    response = fetch_sitemap_response(url)
    return unless response

    parse_sitemap_response(response)
  rescue StandardError => e
    Rails.logger.debug("Failed to fetch sitemap at #{url}: #{e.message}")
    nil
  end

  def fetch_sitemap_response(url)
    response = @http_client.get(url)
    return unless response

    if url.end_with?('.gz')
      Zlib::GzipReader.new(StringIO.new(response)).read
    else
      response
    end
  end

  def parse_sitemap_response(response)
    return unless valid_xml_content?(response)

    doc = Nokogiri::XML(response)
    return unless valid_sitemap?(doc)

    doc
  rescue Nokogiri::XML::SyntaxError => e
    Rails.logger.debug("Invalid sitemap content: #{e.message}")
    nil
  end

  def valid_xml_content?(content)
    content.is_a?(String) && content.strip.start_with?('<?xml', '<urlset', '<sitemapindex')
  end

  def valid_sitemap?(doc)
    doc.errors.empty? && (doc.css('url').any? || doc.css('sitemap').any?)
  end

  def extract_sitemap_urls(doc)
    doc.css('url loc').map(&:text)
  end

  def fetch_url_with_error_handling(url, mutex, results)
    page_response = @http_client.get(url)
    result = {
      url: url,
      html: page_response&.force_encoding("UTF-8")&.scrub
    }
    mutex.synchronize { results << result }
  rescue StandardError => e
    Rails.logger.error("Error fetching URL #{url}: #{e.message}")
    mutex.synchronize { results << { url: url, html: nil } }
  end

  def extract_links(doc)
    doc.css('a[href]').map do |link|
      href = link['href']
      next unless href

      begin
        absolute_url = URI.join("https://#{@domain}", href).to_s
        absolute_url if absolute_url.start_with?("https://#{@domain}")
      rescue URI::InvalidURIError
        nil
      end
    end.compact.uniq
  end
end