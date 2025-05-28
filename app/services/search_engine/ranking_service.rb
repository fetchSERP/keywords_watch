class SearchEngine::RankingService < BaseService
  def initialize(search_engine: "google", country: "us", domain:, pages_number: 10)
    @search_engine = search_engine
    @country = country
    @domain = domain
    @pages_number = pages_number
  end
  def call(query)
    search_results = "SearchEngine::Search::#{@search_engine.capitalize}Service".constantize.new(country: @country, pages_number: @pages_number).call(query)
    results = search_results[:results].select do |result|
      escaped_domain = Regexp.escape(@domain)
      # regex = %r{\Ahttps?://([a-z0-9-]+\.)*#{escaped_domain}(/|$)}i
      regex = %r{\Ahttps?://(?:[a-z0-9-]+\.)*#{escaped_domain}(?:/|$)}i
      !!(result[:url] =~ regex)
    end
    { results: results, errors: search_results[:errors] }
  end
end
