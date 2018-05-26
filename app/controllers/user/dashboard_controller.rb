class User::DashboardController < User::UserController
  before_action :set_user

  def index
    @year = params[:year].blank? ? EDITION : params[:year].to_i
    @offers = @user.offers(@year)
  end

  def support
  end

  private

  def set_user
    @user = current_user
  end
end
