class App::ApplicationController < ApplicationController
  # Credit gating removed – we now rely on live FetchSERP credits
  before_action :ensure_fetchserp_api_key

  private

  def ensure_fetchserp_api_key
    return if controller_name == "users" # allow editing key

    unless Current.user&.fetchserp_api_key.present?
      redirect_to edit_app_user_path, alert: "Please add your FetchSERP API key to continue."
    end
  end
end
