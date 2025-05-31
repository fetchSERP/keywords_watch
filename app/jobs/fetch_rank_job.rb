class FetchRankJob < ApplicationJob
  queue_as :default

  def perform(ranking:, pages_number: 20)
    rankings = FetchSerp::ClientService.new(user: ranking.user).domain_ranking(ranking.keyword.name, ranking.domain.name, ranking.search_engine, ranking.country, pages_number)
    rank = rankings["data"]["results"].first
    if rank.present?
      ranking.update!(rank: rank&.dig("ranking"), url: rank&.dig("url"))
      ranking.keyword.update!(ranking: rank&.dig("ranking"), ranking_url: rank&.dig("url"))
    end
  end
end