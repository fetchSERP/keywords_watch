class CreateSearchEngineResultsJob < ApplicationJob
  queue_as :default

  def perform(keyword:, search_engine: "google", pages_number: 10)
    client = keyword.user.fetchserp_client
    response = client.serp(query: keyword.name, search_engine: search_engine, country: keyword.domain.country, pages_number: pages_number)
    search_engine_results = response["results"] || response["data"]&.dig("results") || []
    search_engine_results.each do |search_engine_result|
      if competitor = Competitor.find_by(user: keyword.user, domain: keyword.domain, domain_name: URI.parse(search_engine_result["url"]).host)
        competitor.increment(:serp_appearances_count).save!
        search_engine_result = create_search_engine_result(search_engine_result, competitor, keyword, search_engine)
        Turbo::StreamsChannel.broadcast_append_to(
          "streaming_channel_#{keyword.user_id}",
          target: "competitors",
          partial: "app/domains/competitor",
          locals: { competitor: competitor }
        )
        Turbo::StreamsChannel.broadcast_update_to(
          "streaming_channel_#{keyword.user_id}",
          target: "search_engine_results_#{keyword.id}",
          partial: "app/domains/keyword_search_engine_results",
          locals: { keyword: keyword }
        )
      else
        competitor = Competitor.create!(
          user: keyword.user,
          domain: keyword.domain,
          domain_name: URI.parse(search_engine_result["url"]).host,
          serp_appearances_count: 1
        )
        search_engine_result = create_search_engine_result(search_engine_result, competitor, keyword, search_engine)
        Turbo::StreamsChannel.broadcast_update_to(
          "streaming_channel_#{keyword.user_id}",
          target: "competitor_#{competitor.id}",
          partial: "app/domains/competitor",
          locals: { competitor: competitor }
        )
        Turbo::StreamsChannel.broadcast_update_to(
          "streaming_channel_#{keyword.user_id}",
          target: "competitors_count",
          partial: "app/domains/competitors_count",
          locals: { domain: keyword.domain }
        )
        Turbo::StreamsChannel.broadcast_update_to(
          "streaming_channel_#{keyword.user_id}",
          target: "search_engine_results_#{keyword.id}",
          partial: "app/domains/keyword_search_engine_results",
          locals: { keyword: keyword }
        )
      end
    end

    KeywordsAiScoreJob.perform_later(domain: keyword.domain, count: 10)

    broadcast_credit(keyword.user)
  end

  def create_search_engine_result(search_engine_result, competitor, keyword, search_engine)
    competitor.search_engine_results.create!(
      user: keyword.user,
      keyword: keyword,
      site_name: search_engine_result["site_name"],
      url: search_engine_result["url"],
      title: search_engine_result["title"],
      description: search_engine_result["description"],
      ranking: search_engine_result["ranking"],
      search_engine: search_engine
    )
  end
end