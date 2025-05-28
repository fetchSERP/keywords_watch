class CreateGoogleAdsKeywordsJob < ApplicationJob
  queue_as :default

  def perform(user:, domain:, count: 10)
    keywords = FetchSerp::ClientService.new.keywords_suggestions(url: "https://#{domain.name}")
    keywords["data"]["keywords_suggestions"].sample(count).each do |keyword|
      next if Keyword.exists?(user: user, name: keyword["keyword"])
      Keyword.create(
        user: user,
        domain: domain,
        name: keyword["keyword"],
        avg_monthly_searches: keyword["avg_monthly_searches"],
        competition: keyword["competition"],
        competition_index: keyword["competition_index"],
        low_top_of_page_bid_micros: keyword["low_top_of_page_bid_micros"],
        high_top_of_page_bid_micros: keyword["high_top_of_page_bid_micros"]
      )
    end
  end
end