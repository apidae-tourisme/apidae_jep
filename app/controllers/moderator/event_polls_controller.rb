class Moderator::EventPollsController < Moderator::ModeratorController
  def index
    @users = User.with_items(GRAND_LYON)
    @users_without_poll = @users.to_a.select {|usr| usr.active_poll.nil?}
  end

  def show
    @poll = EventPoll.find(params[:id])
    @user = @poll.user
    @disabled = 'disabled'
  end

  def export
    @users = User.with_items(GRAND_LYON)
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"questionnaires-#{I18n.l(Time.current, format: :reference)}.xlsx\""
      }
    end
  end

  def notify
    @users = User.with_items(GRAND_LYON)
    @users_without_poll = @users.to_a.select {|usr| usr.active_poll.nil?}

    @users_without_poll.each do |usr|
      NotificationMailer.notify_poll(usr).deliver_later
    end

    redirect_to url_for(action: :index), notice: 'Les notifications ont bien été transmises.'
  end
end
