class Keyword < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  has_many :rankings, dependent: :destroy
  after_create :check_indexation
  after_create :append_to_dom
  after_update :update_dom
  validates :name, presence: true, uniqueness: { scope: :user_id }

  private

  def check_indexation
    CheckKeywordIndexationJob.perform_later(self)
  end

  def update_dom
    Turbo::StreamsChannel.broadcast_replace_to(
      "keywords",
      target: "keyword_#{id}",
      partial: "app/keywords/keyword",
      locals: { keyword: self }
    )
  end

  def append_to_dom
    Turbo::StreamsChannel.broadcast_append_to(
      "keywords",
      target: "keywords",
      partial: "app/keywords/keyword",
      locals: { keyword: self }
    )
  end
end
