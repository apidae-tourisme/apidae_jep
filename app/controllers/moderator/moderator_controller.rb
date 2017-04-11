class Moderator::ModeratorController < ApplicationController
  before_filter :authenticate_moderator!
  layout 'moderator'
end