class GetSearchVolumeJob < ApplicationJob
  queue_as :default

  def perform(keyword:)
    client = keyword.user.fetchserp_client
    response = client.keywords_search_volume(keywords: [keyword.name], country: keyword.domain.country)
    volume_data = response["search_volume"] || response["data"]&.dig("search_volume") || []
    search_volume = volume_data.first
    if search_volume
      keyword.update(
        avg_monthly_searches: search_volume["avg_monthly_searches"],
        competition: search_volume["competition"],
        competition_index: search_volume["competition_index"],
        low_top_of_page_bid_micros: search_volume["low_top_of_page_bid_micros"],
        high_top_of_page_bid_micros: search_volume["high_top_of_page_bid_micros"]
      )
    end

    broadcast_credit(keyword.user)
  end
end