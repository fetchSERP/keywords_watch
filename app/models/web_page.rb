class WebPage < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  validates :url, presence: true, uniqueness: { scope: :domain_id }
end
