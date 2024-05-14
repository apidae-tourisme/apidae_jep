class User::DashboardController < User::UserController
  skip_before_action :check_onboarding, only: [:onboarding, :submit_onboarding]
  before_action :set_user

  def index
    @year = params[:year].blank? ? EDITION : params[:year].to_i
    @offers = @user.offers(@year)
  end

  def support
  end

  def onboarding
    @items = @user.legal_entity.active_items(EDITION - 1).sort_by {|i| 1/i.id.to_f}
    if @items.count == 0
      @user.update(onboarding: '1')
      redirect_to url_for(action: :index)
    end
  end

  def submit_onboarding
    duplicated_offers = params[:duplicated_offers] || []
    duplicated_offers.each do |item_id|
      item = ProgramItem.find(item_id)
      dup_item = ProgramItem.build_from(item)
      dup_item.save
      Rails.logger.info "errors: #{dup_item.errors.full_messages}"
    end
    @user.update(onboarding: '1', gdpr_status: params[:user_gdpr])
    redirect_to url_for(action: :index), notice: "La présélection de vos offres a bien été enregistrée."
  end

  private

  def set_user
    @user = current_user
  end
end
