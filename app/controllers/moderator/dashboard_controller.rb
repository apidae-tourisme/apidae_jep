class Moderator::DashboardController < Moderator::ModeratorController
  def index
    @pending_items = ProgramItem.pending
  end
end
