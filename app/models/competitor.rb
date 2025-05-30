class Competitor < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  has_many :search_engine_results, dependent: :destroy

  after_create_commit :append_to_dom
  after_update_commit :update_dom

  def append_to_dom
    Turbo::StreamsChannel.broadcast_append_to(
      "streaming_channel_#{user_id}",
      target: "competitors",
      partial: "app/domains/competitor",
      locals: { competitor: self }
    )
  end

  def update_dom
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{user_id}",
      target: "competitor_#{id}",
      partial: "app/domains/competitor",
      locals: { competitor: self }
    )
  end
end
