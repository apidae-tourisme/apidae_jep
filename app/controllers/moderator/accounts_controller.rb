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
      if @user.update(user_params)
        redirect_url = url_for(action: :index)
        unless params[:item_id].blank?
          item = ProgramItem.find(params[:item_id])
          redirect_url = edit_moderator_program_program_item_url(item.program_id, item.id)
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
            "de données Apidae.\nLe message fourni est le suivant : #{error_msg}"
      else
        logger.error "Apidae error : #{e.response} - user : #{@user.id}"
        flash.now[:alert] = "Une erreur s'est produite au cours de l'enregistrement dans la base de données Apidae."
      end
    end
    render :edit
  end

  def list_com
    @polls = CommunicationPoll.where(user_id: User.where(territory: current_moderator.member_ref, communication: true).collect {|u| u.id})
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

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit!
  end
end
