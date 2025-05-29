class CreateBacklinksJob < ApplicationJob
  queue_as :default

  def perform(domain)
    backlinks = FetchSerp::ClientService.new.backlinks(domain.name)
    backlinks["data"]["backlinks"].each do |backlink|
      Backlink.create!(
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
    end
  end
end