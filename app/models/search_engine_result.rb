class SearchEngineResult < ApplicationRecord
  belongs_to :user
  belongs_to :keyword
  before_save :populate_domain
  after_commit :update_domain_competitors, on: :create

  private

  def populate_domain
    self.domain = URI.parse(url).host
  end

  def update_domain_competitors
    @domain_competitor = DomainCompetitor.find_or_initialize_by(user: user, domain: keyword.domain, competitor_domain: domain)
    @domain_competitor.keyword_ids << keyword.id
    @domain_competitor.increment(:serp_appearances_count).save!
  end
  
end
