class DailyRankingJob < ApplicationJob
  queue_as :default

  def perform
    User.all.each do |user|
      next unless user.fetchserp_credits > 0

      user.domains.each do |domain|
        domain.keywords.where(is_tracked: true).each do |keyword|
          CreateRankingsJob.perform_later(keyword: keyword)
        end
      end
    end
  end
end