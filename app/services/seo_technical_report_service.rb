class SeoTechnicalReportService < BaseService
  def initialize(web_page:)
    @web_page = web_page
  end

  def call
    FetchSerp::ClientService.new(user: @web_page.user).web_page_seo_analysis(@web_page.url)
  end
end