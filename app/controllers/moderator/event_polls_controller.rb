class Moderator::EventPollsController < Moderator::ModeratorController
  def index
    @users = User.with_items
  end

  def show
    @poll = EventPoll.find(params[:id])
    @user = @poll.user
    @disabled = 'disabled'
  end

  def export
    redirect_to url_for(action: :index)
  end

  def notify
    redirect_to url_for(action: :index)
  end
end
