class Public::SeoPagesController < Public::ApplicationController
  def index
    @seo_pages = SeoPage.page(params[:page]).per(100)
  end

  def show
    @seo_page = SeoPage.find_by(slug: params[:id])
  end
end
