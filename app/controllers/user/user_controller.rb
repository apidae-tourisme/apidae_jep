class User::UserController < ApplicationController
  before_action :authenticate_user!
  before_action :check_entity

  layout 'user'

  def check_entity
    if current_user && current_user.legal_entity_id.nil?
      redirect_to edit_user_account_path(current_user)
    end
  end
end