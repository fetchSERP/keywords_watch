class KeywordsTrackerJob < ApplicationJob
  queue_as :default

  def perform(domain:)
    tracking_keywords = domain.keywords.sample(10)
    tracking_keywords.each do |keyword|
      keyword.update!(is_tracked: true)
    end
  end
end