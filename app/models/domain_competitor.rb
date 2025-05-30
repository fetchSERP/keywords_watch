class DomainCompetitor < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  has_many :search_engine_results, dependent: :destroy

  after_create_commit :append_to_dom
  after_update_commit :update_dom

  def append_to_dom
    Turbo::StreamsChannel.broadcast_append_to(
      "streaming_channel_#{user_id}",
      target: "domain_competitors",
      partial: "app/domains/competitor",
      locals: { domain_competitor: self }
    )
  end

  def update_dom
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{user_id}",
      target: "domain_competitor_#{id}",
      partial: "app/domains/competitor",
      locals: { domain_competitor: self }
    )
  end
end
