class Moderator::DashboardController < Moderator::ModeratorController
  skip_before_filter :is_active_moderator!, only: [:inactive]

  def index
    @items = ProgramItem.in_status(ProgramItem::STATUS_PENDING, current_moderator.member_ref)
  end

  def inactive
    render 'inactive', layout: 'application'
  end
end
