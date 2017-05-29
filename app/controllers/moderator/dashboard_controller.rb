class Moderator::DashboardController < Moderator::ModeratorController
  def index
    @items = ProgramItem.in_status(ProgramItem::STATUS_PENDING, current_moderator.member_ref)
  end
end
