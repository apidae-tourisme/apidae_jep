class User::ProgramItemsController < User::UserController
  before_action :check_auth
  before_action :set_program_item, only: [:edit, :update, :show, :destroy, :confirm, :duplicate]

  def check_auth
    if current_user && current_user.territory == ISERE
      redirect_to user_dashboard_url, alert: "La saisie des offres pour les JEP #{EDITION} n'est plus disponible en ligne."
    end
  end

  def index
    @items = current_user.legal_entity.active_items(params[:year]).sort_by {|i| 1/i.id.to_f}
    @year = params[:year].blank? ? EDITION : params[:year].to_i
    unless params[:status].blank?
      @status = params[:status]
      @items = @items.select {|i| i.status == @status}
    end
  end

  def new
    if params[:id].blank?
      @item = ProgramItem.new_default(current_user)
    else
      @previous_id = params[:id]
      previous_version = ProgramItem.find(params[:id])
      @item = ProgramItem.build_from(previous_version)
      @town = Town.find_by_insee_code(@item.main_town_insee_code) if @item.main_town_insee_code
    end
    render :new, layout: (current_moderator ? 'moderator' : 'user')
  end

  def create
    @item = ProgramItem.new(item_params)

    if @item.save(validate: @item.status != ProgramItem::STATUS_DRAFT)
      @item.comment = nil
      unless @item.reference
        @item.reference = @item.id
        @item.save(validate: @item.status != ProgramItem::STATUS_DRAFT)
      end
      NotificationMailer.notify(@item).deliver_later if @item.pending?
      if @item.user_id && @item.user.territory == GRAND_LYON && @item.user.program_items.count == 1 && @item.user.communication.nil?
        redirect_to communication_user_account_path(user_id: @item.user_id)
      elsif current_moderator
        redirect_to moderator_program_items_url(status: @item.status), notice: "L'offre a bien été créée."
      else
        redirect_to confirm_user_program_item_url(@item)
      end
    else
      render :new, notice: "Une erreur est survenue lors de la création de l'offre.", layout: (current_moderator ? 'moderator' : 'user')
    end
  end

  def edit
    @town = Town.find_by_insee_code(@item.main_town_insee_code) if @item.main_town_insee_code
    render :edit, layout: (current_moderator ? 'moderator' : 'user')
  end

  def update
    @item.attributes = item_params
    if @item.save(validate: @item.status != ProgramItem::STATUS_DRAFT)
      NotificationMailer.notify(@item).deliver_later if @item.pending?
      if current_moderator
        redirect_to moderator_program_items_url(status: @item.status), notice: "L'offre a bien été mise à jour."
      else
        redirect_to confirm_user_program_item_url(@item)
      end
    else
      render :edit, notice: "Une erreur est survenue lors de la mise à jour de l'offre.", layout: (current_moderator ? 'moderator' : 'user')
    end
  end

  def show
    @town = Town.find_by_insee_code(@item.main_town_insee_code) if @item.main_town_insee_code
  end

  def destroy
    if @item.destroy
      if current_moderator
        redirect_to moderator_program_items_url, notice: "Le brouillon a bien été supprimé."
      else
        redirect_to user_program_items_url, notice: "Le brouillon a bien été supprimé."
      end
    else
      if current_moderator
        redirect_to moderator_program_items_url, alert: "Une erreur est survenue lors de la suppression du brouillon."
      else
        flash.now[:alert] = "Une erreur est survenue lors de la suppression du brouillon."
        render :index
      end
    end
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
    @new_item.history = []
    @new_item.openings.each_pair do |d, o|
      if o.is_a?(Hash)
        o['id'] = "#{@new_item.external_ref}-#{d.gsub('-', '')}"
      else
        @new_item.openings[d] = {'id' => "#{@new_item.external_ref}-#{d.gsub('-', '')}"}
      end
    end
    # @item.item_openings.each do |o|
    #   @new_item.item_openings << o.dup
    # end
    if @new_item.save(validate: false)
      @new_item.reference = @new_item.id
      @new_item.save(validate: false)
      @item.attached_files.each do |f|
        AttachedFile.create(data: f.data, picture: f.picture, program_item_id: @new_item.id) unless f.picture_file_name && f.picture_file_name.include?('affiche-jep-isere') && f.picture_file_name != "affiche-jep-isere-#{EDITION}.jpg"
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
    @place = Place.where(uid: params[:place_uid]).first
    jep_site = JepSite.where(place_uid: params[:place_uid]).first
    @site_desc = (jep_site && jep_site.description) ? jep_site.description : ''
    @site_ages = (jep_site && jep_site.ages) ? jep_site.ages : []
  end

  # Emulates a Pelias autocomplete search endpoint
  def entities
    @entities = []
    territory = current_moderator ? current_moderator.member_ref : current_user.territory
    territory_code = territory == SAUMUR ? "49%" : (territory == DLVA ? "04%" : "999%")
    unless params[:text].blank?
      @entities = LegalEntity.where("town_insee_code ILIKE ?", territory_code).matching(params[:text])
                      .where('external_id IS NOT NULL').includes(:town)
    end
  end

  def places
    territory = current_moderator ? current_moderator.member_ref : current_user.territory
    @entities = territory_entities(territory, params[:text])[0..5]
    geo_results = ''
    focus_point = territory == ISERE ? [45.1864, 5.736474] : [45.740410, 4.816417]
    url = "https://places.apidae.net/autocomplete?text=#{params[:text]}&focus.point.lat=#{focus_point.first}&focus.point.lon=#{focus_point.last}&layers=venue%2Caddress%2Cstreet%2Cpostalcode"
    open(url) {|f|
      f.each_line {|line| geo_results += line}
    }
    result = JSON.parse geo_results, symbolize_names: true
    logger.info "search url: #{url} - entities count: #{@entities.count} - geo features count: #{(result[:features] || []).count}"
    @features = @entities.map {|e| e.to_geojson_feature} + (result[:features] || [])
  end

  private

  def item_params
    params.require(:program_item).permit!
  end

  def set_program_item
    @item = ProgramItem.find(params[:id])
    # @item.set_openings
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

  def territory_entities(territory, pattern)
    entities = []
    unless params[:text].blank?
      entities = LegalEntity.where(territory == GRAND_LYON ? "town_insee_code LIKE ?" : "town_insee_code NOT LIKE ?", "69%").matching(pattern)
                             .where('external_id IS NOT NULL').includes(:town)
    end
    entities
  end
end
