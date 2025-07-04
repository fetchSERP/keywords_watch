class CreateBacklinksJob < ApplicationJob
  queue_as :default

  def perform(domain)
    backlinks_response = domain.user.fetchserp_client.backlinks(domain: domain.name, search_engine: "google", country: domain.country, pages_number: 20)
    backlinks_response_data = backlinks_response["backlinks"] || backlinks_response["data"]&.dig("backlinks") || []
    backlinks_response_data.each do |backlink|
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
    broadcast_credit(domain.user)
  end
end