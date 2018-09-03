class User::ProgramItemsController < User::UserController
  before_action :check_auth
  before_action :set_program_item, only: [:edit, :update, :show, :destroy, :confirm, :duplicate]

  def check_auth
    if current_user.territory == ISERE
      redirect_to user_dashboard_url, alert: "La saisie des offres pour l'Isère n'est plus disponible en ligne."
    end
  end

  def index
    @items = current_user.legal_entity.active_items.sort_by {|i| 1/i.id.to_f}
    unless params[:status].blank?
      @status = params[:status]
      @items = @items.select {|i| i.status == @status}
    end
    unless params[:year].blank?
      @year = params[:year].to_i
      @items = @items.select {|i| i.created_at >= Date.new(@year, 1, 1) && i.created_at < Date.new(@year + 1, 1, 1)}
    end
  end

  def new
    if params[:id].blank?
      @item = ProgramItem.new(item_type: ITEM_VISITE, free: true, booking: false,
                              accept_pictures: '0', user_id: current_user.id, rev: 1, status: ProgramItem::STATUS_DRAFT,
                              telephone: current_user.legal_entity.phone, email: current_user.legal_entity.email,
                              website: current_user.legal_entity.website)
    else
      @previous_id = params[:id]
      previous_version = ProgramItem.find(params[:id])
      @item = previous_version.dup
      @item.status = ProgramItem::STATUS_DRAFT
      @item.external_status = nil
      @item.rev += 1
      @item.reference = previous_version.reference
      previous_version.item_openings.each do |o|
        @item.item_openings << o.dup
      end
      previous_version.attached_files.each do |f|
        @item.attached_files << AttachedFile.new(program_item: @item, data: f.data, picture: f.picture, created_at: f.created_at)
      end
      @town = Town.find_by_insee_code(@item.main_town_insee_code) if @item.main_town_insee_code
    end
  end

  def create
    @item = ProgramItem.new(item_params)

    if @item.save(validate: @item.status != ProgramItem::STATUS_DRAFT)
      @item.comment = nil
      unless @item.reference
        @item.reference = @item.id
        @item.save(validate: @item.status != ProgramItem::STATUS_DRAFT)
      end
      NotificationMailer.notify(@item).deliver_now if @item.pending?
      if current_user.territory == GRAND_LYON && current_user.program_items.count == 1 && current_user.communication.nil?
        redirect_to communication_user_account_path
      else
        redirect_to confirm_user_program_item_url(@item)
      end
    else
      render :new, notice: "Une erreur est survenue lors de la création de l'offre."
    end
  end

  def edit
    @town = Town.find_by_insee_code(@item.main_town_insee_code) if @item.main_town_insee_code
  end

  def update
    @item.attributes = item_params
    if @item.save(validate: @item.status != ProgramItem::STATUS_DRAFT)
      NotificationMailer.notify(@item).deliver_now if @item.pending?
      redirect_to confirm_user_program_item_url(@item)
    else
      render :edit, notice: "Une erreur est survenue lors de la mise à jour de l'offre."
    end
  end

  def show
    @town = Town.find_by_insee_code(@item.main_town_insee_code) if @item.main_town_insee_code
  end

  def destroy
  end

  def confirm
  end

  def duplicate
    @new_item = @item.dup
    @new_item.ordering ||= 1
    @new_item.external_id = nil
    @new_item.external_status = nil
    @new_item.rev = 1
    @new_item.user_id = current_user.id
    @new_item.status = ProgramItem::STATUS_DRAFT
    @item.item_openings.each do |o|
      @new_item.item_openings << o.dup
    end
    if @new_item.save(validate: false)
      @new_item.reference = @new_item.id
      @new_item.save(validate: false)
      @item.attached_files.each do |f|
        AttachedFile.create(data: f.data, picture: f.picture, program_item_id: @new_item.id)
      end
      redirect_to edit_user_program_item_url(@new_item), notice: "L'offre a bien été dupliquée."
    else
      render :edit, notice: "Une erreur est survenue lors de la duplication de l'offre."
    end
  end

  def set_opening
    unless params[:prefix].blank?
      opening = opening_params
      @prefix = params[:prefix]
      @starts_at = opening[:starts_at]
      @ends_at = opening[:ends_at]
      @duration = parse_duration(opening[:duration])
      @frequency = parse_duration(opening[:frequency])
      @as_text = ItemOpening.new(opening_params.merge(duration: @duration, frequency: @frequency)).as_text
    end
  end

  def update_form
    @item_type = params[:item_type]
  end

  def site_desc
    @place = Place.where(uid: "f10f8c48-875e-4194-bd7a-33dc2875efef").first
    jep_site = JepSite.where(place_uid: "f10f8c48-875e-4194-bd7a-33dc2875efef").first
    @site_desc = (jep_site && jep_site.description) ? jep_site.description : ''
    @site_ages = (jep_site && jep_site.ages) ? jep_site.ages : []
  end

  private

  def item_params
    params.require(:program_item).permit!
  end

  def set_program_item
    @item = ProgramItem.find(params[:id])
  end

  def opening_params
    params.require(:opening).permit!
  end

  def parse_duration(duration)
    if duration && duration.include?(':')
      duration.split(':')[0].to_i * 3600 + duration.split(':')[1].to_i * 60
    else
      ''
    end
  end
end
