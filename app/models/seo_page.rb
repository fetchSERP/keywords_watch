class SeoPage < ApplicationRecord
  belongs_to :seo_keyword
  belongs_to :pillar, class_name: "SeoPage", foreign_key: "seo_page_id", optional: true
  validates :slug, presence: true, uniqueness: true
end
