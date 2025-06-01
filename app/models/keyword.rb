class Keyword < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  has_many :rankings, dependent: :destroy
  has_many :search_engine_results, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: :user_id }
  after_commit :track, on: :create, if: -> { is_tracked? }
  after_update :track, if: -> { saved_change_to_is_tracked? && is_tracked? }

  private

  def track
    if self.is_tracked
      check_indexation
      create_search_engine_results
      get_search_volume if self.avg_monthly_searches.nil?
    end
  end

  def check_indexation
    CheckKeywordIndexationJob.perform_later(self)
  end

  def create_search_engine_results
    CreateSearchEngineResultsJob.perform_later(keyword: self, search_engine: "google", pages_number: 2)
  end

  def get_search_volume
    GetSearchVolumeJob.perform_later(keyword: self)
  end

end
