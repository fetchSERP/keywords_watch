class FetchRankJob < ApplicationJob
  queue_as :default

  def perform(ranking)
    rankings = FetchSerp::ClientService.new.domain_ranking(ranking.keyword.name, ranking.domain.name, ranking.search_engine, ranking.country, 10)
    rank = rankings["data"]["results"].first
    ranking.update(rank: rank&.dig("ranking"), url: rank&.dig("url"))
  end
end