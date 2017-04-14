require 'raven'

class Moderator::AccountsController < Moderator::ModeratorController
  before_action :set_user, only: [:edit, :update]

  def index
    @accounts = User.all
  end

  def edit
    unless params[:validate].blank?
      @validate = true
    end
  end

  def update
    begin
      if @user.update(user_params)
        if @user.legal_entity.external_id.nil? && @user.legal_entity.remote_save(@user.territory)
          redirect_to url_for(action: :index), notice: "La nouvelle structure a bien été enregistrée." and return
        else
          redirect_to url_for(action: :index), notice: "La structure a bien été mise à jour." and return
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

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit!
  end
end
