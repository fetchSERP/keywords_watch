class Ranking < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  belongs_to :keyword
  after_create :fetch_rank

  private

  def fetch_rank
    FetchRankJob.perform_later(self)
  end
end
