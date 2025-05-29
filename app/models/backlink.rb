class Backlink < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  after_create :append_to_dom

  def append_to_dom
    Turbo::StreamsChannel.broadcast_append_to(
      "backlinks",
      target: "backlinks",
      partial: "app/backlinks/backlink",
      locals: { backlink: self }
    )
  end
end
