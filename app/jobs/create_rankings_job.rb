class CreateRankingsJob < ApplicationJob
  queue_as :default

  def perform(user:, keyword:)
    Ranking.create(
      user: user,
      domain: keyword.domain,
      keyword: keyword,
      search_engine: "google",
      country: "US",
    )
  end
end