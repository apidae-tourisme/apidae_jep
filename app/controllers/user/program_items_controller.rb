class User::ProgramItemsController < User::UserController
  before_action :set_program
  before_action :set_program_item, only: [:edit, :update, :destroy, :confirm, :reorder, :select_program, :save_program,
                                          :duplicate]

  def new
    if params[:id].blank?
      @item = ProgramItem.new(program_id: @program.id, item_type: ITEM_VISITE, free: true, booking: false,
                              accept_pictures: '0', user_id: current_user.id, rev: 1, status: ProgramItem::STATUS_DRAFT,
                              telephone: current_user.legal_entity.phone, email: current_user.legal_entity.email,
                              website: current_user.legal_entity.website)
    else
      previous_version = ProgramItem.find(params[:id])
      @item = previous_version.dup
      @item.status = ProgramItem::STATUS_DRAFT
      @item.external_status = nil
      @item.rev += 1
      @item.reference = previous_version.reference
      previous_version.item_openings.each do |o|
        @item.item_openings << o.dup
      end
      @town = Town.find_by_insee_code(@item.main_town_insee_code) if @item.main_town_insee_code
    end
  end

  def create
    @item = ProgramItem.new(item_params)
    @item.ordering = @program.program_items.count
    if @item.save
      @item.update(reference: @item.id) unless @item.reference
      if current_user.territory == GRAND_LYON && current_user.program_items.count == 1 && current_user.communication.nil?
        redirect_to communication_user_account_path
      else
        redirect_to confirm_user_program_program_item_url(@program.id, @item)
      end
    else
      render :new, notice: "Une erreur est survenue lors de la création de l'offre."
    end
  end

  def edit
    @town = Town.find_by_insee_code(@item.main_town_insee_code) if @item.main_town_insee_code
  end

  def update
    if @item.update(item_params)
      redirect_to confirm_user_program_program_item_url(@program.id, @item)
    else
      render :edit, notice: "Une erreur est survenue lors de la mise à jour de l'offre."
    end
  end

  def destroy
  end

  def confirm
  end

  def reorder
    unless params[:direction].blank?
      ProgramItem.change_order(@item, params[:direction])
    end
    redirect_to edit_user_program_url(@program), notice: "L'offre a bien été mise à jour."
  end

  def select_program
    @programs = Program.joins("INNER JOIN programs_users ON programs_users.program_id = programs.id")
                    .where("programs_users.user_id = ?", current_user.id).collect {|p| [p.title, p.id]}
  end

  def save_program
    if @item.update(item_params)
      redirect_to edit_user_program_url(@item.program), notice: "L'offre a bien déplacée dans sa nouvelle programmation."
    else
      redirect_to edit_user_program_url(@program), notice: "Une erreur est survenue au cours du déplacement de l'offre."
    end
  end

  def duplicate
    @new_item = @item.dup
    @new_item.external_id = nil
    @new_item.external_status = nil
    @new_item.rev = 1
    @new_item.user_id = current_user.id
    @new_item.status = ProgramItem::STATUS_DRAFT
    @item.item_openings.each do |o|
      @new_item.item_openings << o.dup
    end
    if @new_item.save
      @new_item.update(reference: @new_item.id)
      @item.attached_files.each do |f|
        AttachedFile.create(data: f.data, picture: f.picture, program_item_id: @new_item.id)
      end
      redirect_to edit_user_program_url(@program), notice: "L'offre a bien été dupliquée."
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
    @place = Place.where(uid: params[:place_uid]).first
    jep_site = JepSite.where(place_uid: params[:place_uid]).first
    @site_desc = jep_site ? jep_site.description : ''
    @site_ages = jep_site ? jep_site.ages : []
  end

  private

  def item_params
    params.require(:program_item).permit!
  end

  def set_program
    @program = Program.find(params[:program_id])
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
