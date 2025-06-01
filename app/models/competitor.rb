class Competitor < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  has_many :search_engine_results, dependent: :destroy

end
