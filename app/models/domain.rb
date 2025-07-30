class Domain < ApplicationRecord
  after_commit :create_google_ads_keywords, :create_main_keywords, :create_backlinks, :create_domain_infos, :create_web_pages, on: :create
  before_create :set_analysis_status
  belongs_to :user
  has_many :rankings, dependent: :destroy
  has_many :backlinks, dependent: :destroy
  has_many :keywords, dependent: :destroy
  has_many :search_engine_results, through: :keywords
  has_many :competitors, dependent: :destroy
  has_many :web_pages, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :country, presence: true, inclusion: { in: ISO3166::Country.all.map(&:alpha2).map(&:downcase) }

  private

  def create_main_keywords
    CreateMainKeywordsJob.perform_later(domain: self)
  end

  def create_google_ads_keywords
    CreateGoogleAdsKeywordsJob.perform_later(domain: self)
  end

  def create_backlinks
    CreateBacklinksJob.perform_later(self)
  end

  def create_domain_infos
    CreateDomainInfosJob.perform_later(self)
  end

  def create_web_pages
    CreateWebPagesJob.perform_later(domain: self, count: 5)
  end

  def set_analysis_status
    self.analysis_status = {
      "default_keywords" => false,
      "google_ads_keywords" => false,
      "fetch_backlinks" => false,
      "domain_infos" => false,
      "scrape_domain" => false,
      "technical_seo_report" => false,
    }
  end
end
