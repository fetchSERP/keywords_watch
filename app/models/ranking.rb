class Ranking < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  belongs_to :keyword
  after_commit :fetch_rank, on: :create

  private

  def fetch_rank
    FetchRankJob.perform_later(ranking: self, pages_number: 20)
  end

end
