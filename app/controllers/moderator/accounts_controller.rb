require 'raven'

class Moderator::AccountsController < Moderator::ModeratorController
  before_action :set_user, only: [:edit, :update, :edit_com, :update_com]

  def index
    @accounts = User.where(territory: current_moderator.member_ref)
  end

  def edit
    unless params[:validate].blank?
      @validate = true
      @item_id = params[:item_id]
    end
  end

  def update
    begin
      if set_entity && @user.update(user_params)
        redirect_url = url_for(action: :index)
        unless params[:item_id].blank?
          item = ProgramItem.find(params[:item_id])
          redirect_url = edit_moderator_program_item_url(item.id)
        end
        if @user.legal_entity.external_id.nil? && @user.legal_entity.remote_save(@user.territory)
          redirect_to redirect_url, notice: "La nouvelle structure a bien été enregistrée." and return
        else
          redirect_to redirect_url, notice: "La structure a bien été mise à jour." and return
        end
      end
    rescue OAuth2::Error => e
      Raven.capture_exception(e)
      if e.response.parsed
        logger.error "Apidae error : #{e.response.parsed['errorType']} - #{e.response.parsed['message']} - user : #{@user.id}"
        error_msg = e.response.parsed['message']
        error_msg = error_msg.split("\n").first if error_msg && error_msg.include?("\n")
        flash.now[:alert] = "Une erreur s'est produite au cours de l'enregistrement dans la base " +
            "de données Apidae. Le message fourni est le suivant : #{error_msg}"
      else
        logger.error "Apidae error : #{e.response} - user : #{@user.id}"
        flash.now[:alert] = "Une erreur s'est produite au cours de l'enregistrement dans la base de données Apidae."
      end
    end
    render :edit
  end

  def list_com
    @polls = CommunicationPoll.where(user_id: User.where(territory: current_moderator.member_ref, communication: true).collect {|u| u.id})
    @users = User.with_items(GRAND_LYON)
    @users_without_com = @users.to_a.select {|usr| usr.communication_poll.nil?}
  end

  def edit_com
  end

  def update_com
    if @user.update(user_params)
      redirect_to url_for(action: :list_com), notice: "Le formulaire a bien été enregistré."
    else
      render :edit_com, notice: "Une erreur s'est produite lors de l'enregistrement du formulaire."
    end
  end

  def export
    @accounts = User.where(territory: current_moderator.member_ref)
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"organisateurs-#{current_moderator.member_ref}-#{I18n.l(Time.current, format: :reference)}.xlsx\""
      }
    end
  end

  def export_com
    @polls = CommunicationPoll.where(user_id: User.where(territory: current_moderator.member_ref, communication: true).collect {|u| u.id})
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"supports-com-#{current_moderator.member_ref}-#{I18n.l(Time.current, format: :reference)}.xlsx\""
      }
    end
  end

  def notify_com
    @users = User.with_items(GRAND_LYON)
    @users_without_com = @users.to_a.select {|usr| usr.communication_poll.nil?}

    @users_without_com.each do |usr|
      NotificationMailer.notify_com(usr).deliver_later
    end

    redirect_to url_for(action: :list_com), notice: 'Les notifications ont bien été transmises.'
  end

  private

  def set_entity
    entity_id = user_params[:legal_entity_attributes][:id]
    if !entity_id.blank? && @user.legal_entity_id != entity_id.to_i
      @user.legal_entity = LegalEntity.find(entity_id)
      @user.save
    else
      true
    end
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit!
  end
end
