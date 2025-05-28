class Ai::Seo::BacklinksService < BaseService
  def initialize(domain:, pages_number: 15, search_engine: "google", country: "us")
    @domain = domain
    @pages_number = pages_number
    @search_engine = search_engine
    @country = country
  end

  def call
    serp = SearchEngine::QueryService.new(
      search_engine: @search_engine,
      country: @country,
      pages_number: @pages_number,
    ).call("\"#{@domain}\" -site:#{@domain}")
    if(serp[:errors].any?)
      @error = serp[:errors].map { |e| e[:message] }.join(", ")
      response.status = :unprocessable_entity
      return
    end
    results = []
    serp[:results].each_slice(10) do |batch|
      threads = batch.map do |serp_result|
        Thread.new do
          begin
            serp_result = serp_result.with_indifferent_access
            raise "invalid url" if serp_result[:url] == "N/A"
            response_body = Scraper::HttpClientService.new.call(serp_result[:url])
            doc = Nokogiri::HTML(response_body.force_encoding("UTF-8").scrub)
            serp_result[:content] = doc
            serp_result
          rescue StandardError => e
            serp_result[:content] = "Error scraping page: #{e.message}"
            serp_result
          end
        end
      end
      results.concat(threads.map(&:value))
    end

    results.map do |result|
      source_url = result["url"]
    
      doc = if result["content"].is_a?(String)
              Nokogiri::HTML(result["content"])
            else
              result["content"]
            end
    
      backlinks = doc.css('a').select { |a| a['href']&.include?("#{@domain}") }
    
      backlinks.map do |a|
        rel_attrs = a['rel'].to_s.split(' ')
        {
          source_url: source_url,
          target_url: a['href'],
          anchor_text: a.inner_text.to_s.strip,
          nofollow: rel_attrs.include?('nofollow'),
          rel_attributes: rel_attrs,
          context_text: a.parent ? a.parent.inner_text.to_s.strip : '',
          source_domain: URI.parse(source_url).host,
          target_domain: URI.parse(a['href']).host,
          page_title: doc.title,
          meta_description: doc.css('meta[name="description"]')&.first&.[]('content'),
        }
      end
    end.flatten
  end

end