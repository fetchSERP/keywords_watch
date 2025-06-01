class KeywordsTrackerJob < ApplicationJob
  queue_as :default

  def perform(domain:, count:)
    domain.keywords.order(ai_score: :desc).first(count).each do |keyword|
      keyword.update!(is_tracked: true)
      Turbo::StreamsChannel.broadcast_replace_to(
        "streaming_channel_#{domain.user_id}",
        target: "keyword_#{keyword.id}",
        partial: "app/keywords/keyword",
        locals: { keyword: keyword }
      )
      Turbo::StreamsChannel.broadcast_update_to(
        "streaming_channel_#{domain.user_id}",
        target: "tracked_keywords_count",
        partial: "app/domains/tracked_keywords_count",
        locals: { domain: domain }
      )
    end
  end
end
