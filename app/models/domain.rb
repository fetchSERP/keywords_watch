class Domain < ApplicationRecord
  after_commit :create_google_ads_keywords, :create_main_keywords, :create_backlinks, on: :create
  belongs_to :user
  has_many :rankings, dependent: :destroy
  has_many :backlinks, dependent: :destroy
  has_many :keywords, dependent: :destroy
  has_many :search_engine_results, through: :keywords
  has_many :competitors, dependent: :destroy
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :country, presence: true, inclusion: { in: ISO3166::Country.all.map(&:alpha2).map(&:downcase) }

  private

  def create_main_keywords
    ["#{self.name.split(".").first}"].each do |keyword|
      Keyword.create(
        user: user,
        domain: self,
        name: keyword
      )  
    end
  end

  def create_google_ads_keywords
    CreateGoogleAdsKeywordsJob.perform_later(domain: self, count: 10)
  end

  def create_backlinks
    CreateBacklinksJob.perform_later(self)
  end
end
