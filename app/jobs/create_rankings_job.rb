class CreateRankingsJob < ApplicationJob
  queue_as :default

  def perform(keyword:)
    Ranking.create(
      user: keyword.user,
      domain: keyword.domain,
      keyword: keyword,
      search_engine: "google",
      country: "us",
    )
  end
end