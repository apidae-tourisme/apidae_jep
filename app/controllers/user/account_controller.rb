class User::AccountController < User::UserController
  skip_before_filter :check_entity
  skip_before_filter :authenticate_user!, only: [:towns, :search_entity]

  def edit
    @user = current_user
    @user.legal_entity ||= LegalEntity.new
  end

  def update
    @user = current_user
    if !entity_params[:id].blank?
      legal_entity_id = entity_params[:id]
      legal_entity = LegalEntity.find(entity_params[:id])
      legal_entity.update(entity_params)
      update_params = user_params.except(:legal_entity_attributes).merge(legal_entity_id: legal_entity_id)
    else
      update_params = user_params
    end
    if @user.update(update_params)
      redirect_to user_dashboard_url, notice: "Le compte a bien été mis à jour."
    else
      render :edit
    end
  end

  def search_entity
    if params[:pattern]
      @entities = LegalEntity.matching(params[:pattern]).includes(:town).where('external_id IS NOT NULL')
    end
  end

  def towns
    @towns = []
    unless params[:pattern].blank?
      @towns = Town.matching(URI.decode(params[:pattern]))
    end
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def entity_params
    params.require(:user).require(:legal_entity_attributes).permit!
  end
end
