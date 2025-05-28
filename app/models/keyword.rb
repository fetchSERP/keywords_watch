class Keyword < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  has_many :rankings, dependent: :destroy
  after_create :create_rankings
  validates :name, presence: true, uniqueness: { scope: :user_id }

  private

  def create_rankings
    CreateRankingsJob.perform_later(user: user, keyword: self)
  end
end
