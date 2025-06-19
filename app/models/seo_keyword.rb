class SeoKeyword < ApplicationRecord
  belongs_to :pillar, class_name: "SeoKeyword", foreign_key: "seo_keyword_id", optional: true
  has_one :seo_page, dependent: :destroy
  after_create_commit :create_seo_page
  after_create_commit :create_long_tail_seo_keywords, unless: :is_long_tail?
  enum :search_intent, { informational: 0, navigational: 1, commercial: 2, transactional: 3 }
  validates :name, presence: true, uniqueness: true

  private

  def create_seo_page
    CreateSeoPageJob.perform_later(self)
  end

  def create_long_tail_seo_keywords
    CreateLongTailSeoKeywordsJob.perform_later(seed_keyword: self, count: 10)
  end
end
