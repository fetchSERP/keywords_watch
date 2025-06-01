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
  end
end