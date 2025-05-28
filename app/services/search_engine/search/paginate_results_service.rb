class SearchEngine::Search::PaginateResultsService < BaseService
  MAX_THREADS = 30
  MAX_RETRIES = 10

  def initialize(search_service)
    @search_service = search_service
  end

  def call(query)
    results = []
    errors = []
    mutex = Mutex.new

    (0...@search_service.pages_number).each_slice(MAX_THREADS) do |page_batch|
      threads = []
      page_batch.each do |page_number|
        threads << Thread.new do
          page_url = @search_service.get_page_url(query, page_number)

          retry_count = 0
          begin
            Rails.logger.info("Fetching page #{page_number + 1}")

            html = Scraper::ProxyFetcherService.new(country: @search_service.country).call(page_url)
            position_offset = page_number * @search_service.results_per_page
            json = @search_service.parse_results(html, position_offset)
            page_results = json[:search_results]
            
            mutex.synchronize do
              results.concat(page_results)
            end

          rescue => e
            retry_count += 1
            Rails.logger.error("Error fetching page #{page_number + 1} (attempt #{retry_count}/#{MAX_RETRIES}): #{e.message}")
            
            if retry_count < MAX_RETRIES
              retry
            else
              mutex.synchronize do
                errors << { 
                  page: page_number + 1, 
                  message: e.message,
                  attempts: retry_count
                }
              end
            end
          end
        end
      end

      threads.each(&:join)
    end

    {
      results: results,
      errors: errors,
    }
  end
end