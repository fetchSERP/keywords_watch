class WebPage < ApplicationRecord
  belongs_to :user
  belongs_to :domain
  has_one :technical_seo_report, dependent: :destroy
  validates :url, presence: true, uniqueness: { scope: :domain_id }
end
