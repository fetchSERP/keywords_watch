class TechnicalSeoReportJob < ApplicationJob
  queue_as :default

  def perform(domain:)
    domain.web_pages.each do |web_page|
      report = SeoTechnicalReportService.new(web_page: web_page).call
      technical_seo_report = web_page.create_technical_seo_report!(user: web_page.user, url: web_page.url, analysis: report["data"]["analysis"])
      Turbo::StreamsChannel.broadcast_append_to(
        "streaming_channel_#{web_page.user.id}",
        target: "technical_seo_reports",
        partial: "app/domains/technical_seo_report",
        locals: { technical_seo_report: technical_seo_report }
      )
    end
    domain.with_lock do
      domain.update!(analysis_status: domain.analysis_status.merge("technical_seo_report" => true))
    end
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{domain.user_id}",
      target: "domain_analysis_status",
      partial: "app/domains/domain_analysis_status",
      locals: { domain: domain }
    )
  end
end