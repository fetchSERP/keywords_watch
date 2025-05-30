class CreateSearchEngineResultsJob < ApplicationJob
  queue_as :default

  def perform(keyword:, search_engine: "google", count: 10)
    search_engine_results = FetchSerp::ClientService.new.search_engine_results(keyword.name, search_engine, keyword.domain.country, count)
    search_engine_results["data"]["results"].each do |search_engine_result|
      domain_competitor = DomainCompetitor.find_or_initialize_by(user: keyword.user, domain: keyword.domain, competitor_domain: URI.parse(search_engine_result["url"]).host)
      domain_competitor.increment(:serp_appearances_count).save!
      domain_competitor.search_engine_results.create!(
        user: keyword.user,
        keyword: keyword,
        site_name: search_engine_result["site_name"],
        url: search_engine_result["url"],
        title: search_engine_result["title"],
        description: search_engine_result["description"],
        ranking: search_engine_result["ranking"],
        search_engine: search_engine
      )
    end
  end
end