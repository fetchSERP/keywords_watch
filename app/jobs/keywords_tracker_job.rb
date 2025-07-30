class KeywordsTrackerJob < ApplicationJob
  queue_as :default

  def perform(domain:)
    domain.keywords.where(is_tracked: false).order(ai_score: :desc).limit(domain.tracked_keywords_count).each do |keyword|
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
    domain.with_lock do
      domain.update!(analysis_status: domain.analysis_status.merge("track_keywords" => true))
    end
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{domain.user_id}",
      target: "domain_analysis_status",
      partial: "app/domains/domain_analysis_status",
      locals: { domain: domain }
    )
  end
end
