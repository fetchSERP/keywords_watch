class CreateGoogleAdsKeywordsJob < ApplicationJob
  queue_as :default

  def perform(domain:)
    client = domain.user.fetchserp_client
    response = client.keywords_suggestions(url: "https://#{domain.name}")
    suggestions = response["keywords_suggestions"] || response["data"]&.dig("keywords_suggestions") || []
    suggestions.each_with_index do |keyword, index|
      next if Keyword.exists?(user: domain.user, name: keyword["keyword"])
      keyword = Keyword.create(
        user: domain.user,
        domain: domain,
        name: keyword["keyword"].downcase,
        avg_monthly_searches: keyword["avg_monthly_searches"],
        competition: keyword["competition"],
        competition_index: keyword["competition_index"],
        low_top_of_page_bid_micros: keyword["low_top_of_page_bid_micros"],
        high_top_of_page_bid_micros: keyword["high_top_of_page_bid_micros"],
        is_tracked: index < domain.tracked_keywords_count - 1
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
      if index < domain.tracked_keywords_count - 1
        Turbo::StreamsChannel.broadcast_update_to(
          "streaming_channel_#{domain.user_id}",
          target: "tracked_keywords_count",
          partial: "app/domains/tracked_keywords_count",
          locals: { domain: domain }
        )
      end
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
    broadcast_credit(domain.user)
  end

end