class Moderator::AccountsController < Moderator::ModeratorController
  before_action :set_user, only: [:edit, :update]

  def index
    @accounts = User.all
  end

  def edit
  end

  def update
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

  def set_user
    @user = User.find(params[:id])
  end
end
