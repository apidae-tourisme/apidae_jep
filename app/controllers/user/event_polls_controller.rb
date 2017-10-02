class User::EventPollsController < ApplicationController
  layout 'user'

  def new
    @user = User.find(params[:user_id])
    if @user.event_poll
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
    @user = User.find(params[:user_id])
    if !@user.event_poll
      redirect_to url_for(action: :new)
    else
      @poll = @user.last_poll
      @disabled = 'disabled'
    end
  end

  private

  def event_poll_params
    params.require(:event_poll).permit!
  end
end
