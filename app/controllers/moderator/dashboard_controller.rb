class Moderator::DashboardController < Moderator::ModeratorController
  skip_before_action :is_active_moderator!, only: [:inactive]

  def index
    @year = params[:year].blank? ? EDITION : params[:year].to_i
    @items = ProgramItem.in_status(current_moderator.member_ref, @year, ProgramItem::STATUS_PENDING)
  end

  def inactive
    render 'inactive', layout: 'application'
  end
end
