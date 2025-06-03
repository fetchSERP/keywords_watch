class CreateBacklinksJob < ApplicationJob
  queue_as :default

  def perform(domain)
    backlinks = FetchSerp::ClientService.new(user: domain.user).backlinks(domain.name, "google", domain.country, 20)
    backlinks["data"]["backlinks"].each do |backlink|
      backlink = Backlink.create!(
        user: domain.user,
        domain: domain,
        source_url: backlink["source_url"],
        target_url: backlink["target_url"],
        anchor_text: backlink["anchor_text"],
        nofollow: backlink["nofollow"],
        rel_attributes: backlink["rel_attributes"],
        context_text: backlink["context_text"],
        source_domain: backlink["source_domain"],
        target_domain: backlink["target_domain"],
        page_title: backlink["page_title"],
        meta_description: backlink["meta_description"]
      )
      Turbo::StreamsChannel.broadcast_append_to(
        "streaming_channel_#{domain.user_id}",
        target: "backlinks",
        partial: "app/backlinks/backlink",
        locals: { backlink: backlink }
      )
      Turbo::StreamsChannel.broadcast_update_to(
        "streaming_channel_#{domain.user_id}",
        target: "backlinks_count",
        partial: "app/domains/backlinks_count",
        locals: { domain: domain }
      )
    end
    domain.with_lock do
      domain.update!(analysis_status: domain.analysis_status.merge("fetch_backlinks" => true))
    end
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{domain.user_id}",
      target: "domain_analysis_status",
      partial: "app/domains/domain_analysis_status",
      locals: { domain: domain }
    )
  end
end