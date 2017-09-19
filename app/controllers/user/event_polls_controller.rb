class User::EventPollsController < User::UserController
  def new
    @user = current_user
    if current_user.event_poll
      redirect_to url_for(action: :show)
    else
      @poll = EventPoll.new(user_id: @user.id)
      @disabled = nil
    end
  end

  def create
    @poll = EventPoll.create!(event_poll_params)
  end

  def show
    @user = current_user
    @poll = current_user.last_poll
    @disabled = 'disabled'
  end

  private

  def event_poll_params
    params.require(:event_poll).permit!
  end
end
