class App::ApplicationController < ApplicationController
  before_action :check_user_credit
  private

  def check_user_credit
    if Current.user.credit <= 0
      redirect_to root_path, alert: "You need to add credits to your account to continue."
    end
  end
end
