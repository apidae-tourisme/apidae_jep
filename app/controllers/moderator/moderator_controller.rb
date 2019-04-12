class Moderator::ModeratorController < ApplicationController
  before_action :authenticate_moderator!
  before_action :is_active_moderator!
  layout 'moderator'

  def is_active_moderator!
    unless current_moderator && current_moderator.active
      redirect_to moderator_inactive_url, alert: 'Votre compte est inactif.'
    end
  end
end