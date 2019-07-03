class User::UserController < ApplicationController
  before_action :check_authentication
  before_action :check_entity

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
end