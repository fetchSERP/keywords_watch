class CreateDomainInfosJob < ApplicationJob
  queue_as :default

  def perform(domain)
    infos = FetchSerp::ClientService.new(user: domain.user).domain_infos(domain.name)
    domain.update(infos: infos["data"]["domain_info"])
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
  end
end