class User::UserController < ApplicationController
  before_action :check_authentication
  before_action :check_entity
  before_action :check_onboarding

  layout 'user'

  def check_authentication
    if moderator_signed_in?
      true
    else
      authenticate_user!
    end
  end

  def check_entity
    if current_user && current_user.legal_entity_id.nil?
      redirect_to edit_user_account_path(current_user)
    end
  end

  def check_onboarding
    if current_user && !current_user.onboarding
      redirect_to user_onboarding_path
    end
  end
end