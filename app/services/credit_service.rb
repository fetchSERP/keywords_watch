class CreditService < BaseService
  def initialize(user:)
    @user = user
  end

  def call(path:, params:)
    @user.with_lock do
      cost = api_session_cost(path: path, params: params)
      @user.update!(credit: @user.credit - cost)
    end
    Turbo::StreamsChannel.broadcast_replace_to(
      "streaming_channel_#{@user.id}",
      target: "user_credit",
      partial: "shared/user_credit",
      locals: { user: @user }
    )
  end

  def api_session_cost(path:, params:)
    case path
    when "/api/v1/serp"
      params[:pages_number].present? ? params[:pages_number].to_i : 1
    when "/api/v1/serp_html"
      params[:pages_number].present? ? params[:pages_number].to_i * 2 : 2
    when "/api/v1/serp_text"
      params[:pages_number].present? ? params[:pages_number].to_i * 2 : 2
    when "/api/v1/ranking"
      params[:pages_number].present? ? params[:pages_number].to_i : 10
    when "/api/v1/scrape_web_page"
      return 1
    when "/api/v1/scrape_js_web_page"
      return 5
    when "/api/v1/scrape_domain"
      params[:max_pages].present? ? params[:max_pages].to_i : 10
    when "/api/v1/keywords_search_volume"
      return 2
    when "/api/v1/keywords_suggestions"
      return 3
    when "/api/v1/backlinks"
      params[:pages_number].present? ? params[:pages_number].to_i * 2 : 30
    when "/api/v1/seo_analysis"
      return 5
    when "/api/v1/domain_emails"
      params[:pages_number].present? ? params[:pages_number].to_i * 2 : 2
    when "/api/v1/web_page_ai_analysis"
      return 10
    when "/api/v1/page_indexation"
      return 1
    when "/api/v1/long_tail_keywords_generator"
      return 10
    when "/api/v1/domain_infos"
      return 5
    else
      return 0
    end
  end

end