class CreateGoogleAdsKeywordsJob < ApplicationJob
  queue_as :default

  def perform(domain:)
    keywords = FetchSerp::ClientService.new(user: domain.user).keywords_suggestions(url: "https://#{domain.name}")
    keywords["data"]["keywords_suggestions"].each do |keyword|
      next if Keyword.exists?(user: domain.user, name: keyword["keyword"])
      keyword = Keyword.create(
        user: domain.user,
        domain: domain,
        name: keyword["keyword"].downcase,
        avg_monthly_searches: keyword["avg_monthly_searches"],
        competition: keyword["competition"],
        competition_index: keyword["competition_index"],
        low_top_of_page_bid_micros: keyword["low_top_of_page_bid_micros"],
        high_top_of_page_bid_micros: keyword["high_top_of_page_bid_micros"]
      )
      Turbo::StreamsChannel.broadcast_append_to(
        "streaming_channel_#{domain.user_id}",
        target: "keywords",
        partial: "app/keywords/keyword",
        locals: { keyword: keyword }
      )
      Turbo::StreamsChannel.broadcast_update_to(
        "streaming_channel_#{domain.user_id}",
        target: "keywords_count",
        partial: "app/domains/keywords_count",
        locals: { domain: domain }
      )
    end
    domain.with_lock do
      domain.update!(analysis_status: domain.analysis_status.merge("google_ads_keywords" => true))
    end
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{domain.user_id}",
      target: "domain_analysis_status",
      partial: "app/domains/domain_analysis_status",
      locals: { domain: domain }
    )
    CreateWebPagesJob.perform_later(domain: domain, count: 10)
  end

end