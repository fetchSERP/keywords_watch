class FetchRankJob < ApplicationJob
  queue_as :default

  def perform(ranking:, pages_number: 20)
    rankings = FetchSerp::ClientService.new(user: ranking.user).domain_ranking(ranking.keyword.name, ranking.domain.name, ranking.search_engine, ranking.country, pages_number)
    rank = rankings["data"]["results"].first
    if rank.present?
      ranking.update!(rank: rank&.dig("ranking"), url: rank&.dig("url"))
      ranking.keyword.update!(ranking: rank&.dig("ranking"), ranking_url: rank&.dig("url"))
      Turbo::StreamsChannel.broadcast_replace_to(
        "streaming_channel_#{ranking.user_id}",
        target: "keyword_#{ranking.keyword.id}",
        partial: "app/keywords/keyword",
        locals: { keyword: ranking.keyword }
      )
      Turbo::StreamsChannel.broadcast_update_to(
        "streaming_channel_#{ranking.user_id}",
        target: "ranked_keywords_count",
        partial: "app/domains/ranked_keywords_count",
        locals: { domain: ranking.domain }
      )
      Turbo::StreamsChannel.broadcast_update_to(
        "streaming_channel_#{ranking.user_id}",
        target: "domain_avg_rank",
        partial: "app/domains/avg_rank",
        locals: { domain: ranking.domain }
      )
    end
  end
end

