class CreateMainKeywordsJob < ApplicationJob
  queue_as :default

  def perform(domain:)
    ["#{domain.name.split(".").first}"].each do |keyword|
      Keyword.create(
        user: domain.user,
        domain: domain,
        name: keyword.downcase,
        is_tracked: true
      )  
    end
    domain.with_lock do
      domain.update!(analysis_status: domain.analysis_status.merge("default_keywords" => true))
    end
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{domain.user_id}",
      target: "domain_analysis_status",
      partial: "app/domains/domain_analysis_status",
      locals: { domain: domain }
    )
  end
end