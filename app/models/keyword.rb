class Keyword < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  has_many :rankings, dependent: :destroy
  after_create :check_indexation
  validates :name, presence: true, uniqueness: { scope: :user_id }

  private

  def check_indexation
    CheckKeywordIndexationJob.perform_later(self)
  end
end
