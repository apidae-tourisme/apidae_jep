class User::DashboardController < User::UserController
  before_action :set_user

  def index
    @programs = @user.programs
  end

  private

  def set_user
    @user = current_user
  end
end
