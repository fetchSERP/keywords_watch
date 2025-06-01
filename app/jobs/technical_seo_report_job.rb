class TechnicalSeoReportJob < ApplicationJob
  queue_as :default

  def perform(domain:)
    domain.web_pages.each do |web_page|
      report = SeoTechnicalReportService.new(web_page: web_page).call
      web_page.create_technical_seo_report!(user: web_page.user, url: web_page.url, analysis: report["data"]["analysis"])
    end
  end
end