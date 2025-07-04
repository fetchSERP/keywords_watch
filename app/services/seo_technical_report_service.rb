class SeoTechnicalReportService < BaseService
  def initialize(web_page:)
    @web_page = web_page
  end

  def call
    @web_page.user.fetchserp_client.web_page_seo_analysis(url: @web_page.url).tap do
      ApplicationJob.new.broadcast_credit(@web_page.user)
    end
  end
end