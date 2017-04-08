class User::UserController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_entity

  layout 'user'

  def check_entity
    if current_user && current_user.legal_entity_id.nil?
      redirect_to edit_user_account_path(current_user)
    end
  end
end