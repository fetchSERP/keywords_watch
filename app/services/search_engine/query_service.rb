class SearchEngine::QueryService < BaseService
  def initialize(search_engine: "google", country: "us", pages_number: 1)
    @search_engine = search_engine
    @country = country
    @pages_number = pages_number
  end
  def call(query)
    "SearchEngine::Search::#{@search_engine.capitalize}Service".constantize.new(country: @country, pages_number: @pages_number).call(query)
    # serp.reject { |ser| ser.any? { |_, value| value == "N/A" } }
  end
end
