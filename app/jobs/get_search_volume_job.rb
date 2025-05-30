class GetSearchVolumeJob < ApplicationJob
  queue_as :default

  def perform(keyword:)
    search_volume = FetchSerp::ClientService.new.keywords_search_volume([keyword.name], keyword.domain.country)
    search_volume = search_volume["data"]["search_volume"].first
    if search_volume
      keyword.update(
        avg_monthly_searches: search_volume["avg_monthly_searches"],
        competition: search_volume["competition"],
        competition_index: search_volume["competition_index"],
        low_top_of_page_bid_micros: search_volume["low_top_of_page_bid_micros"],
        high_top_of_page_bid_micros: search_volume["high_top_of_page_bid_micros"]
      )
    end
  end
end