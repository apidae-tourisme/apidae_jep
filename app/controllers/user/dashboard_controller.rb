class User::DashboardController < User::UserController
  before_action :set_user

  def index
    @offers = @user.offers
  end

  def support
  end

  private

  def set_user
    @user = current_user
  end
end
