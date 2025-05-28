class Domain < ApplicationRecord
  after_create :create_main_keywords
  after_create :create_google_ads_keywords
  belongs_to :user
  has_many :rankings, dependent: :destroy
  has_many :backlinks, dependent: :destroy
  has_many :keywords, dependent: :destroy

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
    CreateGoogleAdsKeywordsJob.perform_later(user: user, domain: self, count: 10)
  end
end
