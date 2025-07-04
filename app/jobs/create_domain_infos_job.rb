class CreateDomainInfosJob < ApplicationJob
  queue_as :default

  def perform(domain)
    client = domain.user.fetchserp_client
    response = client.domain_infos(domain: domain.name)
    info_data = response["domain_info"] || response["data"]&.dig("domain_info")
    domain.update(infos: info_data)
    Turbo::StreamsChannel.broadcast_update_to(
      "streaming_channel_#{domain.user_id}",
      target: "domain_infos",
      partial: "app/domains/domain_infos",
      locals: { domain: domain }
    )
    domain.with_lock do
      domain.update!(analysis_status: domain.analysis_status.merge("domain_infos" => true))
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