#encoding: UTF-8

require 'raven'

class Moderator::ProgramItemsController < Moderator::ModeratorController
  before_action :set_program_item, only: [:show, :edit, :update, :destroy, :confirm]

  def index
    @year = params[:year].blank? ? EDITION : params[:year].to_i
    @status = params[:status] || ProgramItem::STATUS_PENDING
    @items = ProgramItem.in_status(current_moderator.member_ref, @year, @status)
    @items.each {|item| item.set_territory(current_moderator.member_ref)}
  end

  def export
    @items = ProgramItem.in_status(current_moderator.member_ref, EDITION,
                                   ProgramItem::STATUS_PENDING, ProgramItem::STATUS_VALIDATED, ProgramItem::STATUS_REJECTED)
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"offres-#{current_moderator.member_ref}-#{I18n.l(Time.current, format: :reference)}.xlsx\""
      }
    end
  end

  def show
    @town = Town.find_by_insee_code(@item.main_town_insee_code) if @item.main_town_insee_code
    @prev_item = ProgramItem.where(reference: @item.reference, rev: @item.rev - 1).first
  end

  def edit
    if @item.user.legal_entity.external_id.nil?
      redirect_to edit_moderator_account_url(@item.user, validate: true, item_id: @item.id), notice: "Validation de la structure organisatrice requise"
    end
    @town = Town.find_by_insee_code(@item.main_town_insee_code) if @item.main_town_insee_code
    @prev_item = ProgramItem.where(reference: @item.reference, rev: @item.rev - 1).first
    @entity_items = @item.user.legal_entity.active_items(EDITION).select {|itm| itm.validated?}
  end

  def update
    begin
      @item.attributes = item_params
      if @item.validated?
        if @item.save
          if @item.remote_save
            NotificationMailer.publish(@item).deliver_now
            redirect_to moderator_program_items_url, notice: "L'offre a bien été enregistrée." and return
          end
        end
      elsif @item.save
        NotificationMailer.reject(@item).deliver_now if @item.rejected?
        redirect_to moderator_program_items_url, notice: "L'offre a bien été mise à jour." and return
      end
    rescue Encoding::UndefinedConversionError => e
      Raven.capture_exception(e)
      logger.error("Apidae error - encoding issue : #{e}")
      flash.now[:alert] = "Une erreur technique s'est produite lors de la transmission de l'offre à Apidae"
    rescue OAuth2::Error => e
      Raven.capture_exception(e)
      if e.response.parsed
        logger.error "Apidae error : #{e.response.parsed['errorType']} - #{e.response.parsed['message']} - item : #{@item.id}"
        error_msg = e.response.parsed['message']
        error_msg = error_msg.split("\n").first if error_msg && error_msg.include?("\n")
        flash.now[:alert] = "Une erreur s'est produite au cours de l'enregistrement dans la base " +
            "de données Apidae. Le message fourni est le suivant : #{error_msg}"
      else
        logger.error "Apidae error : #{e.response} - item : #{@item.id}"
        flash.now[:alert] = "Une erreur s'est produite au cours de l'enregistrement dans la base de données Apidae."
      end
    rescue Exception => e
      Raven.capture_exception(e)
      logger.error "Exception caught : #{e}"
      flash.now[:alert] = "Une erreur est survenue lors de la mise à jour de l'offre."
    end
    @item.status = ProgramItem::STATUS_PENDING
    @item.save
    @town = Town.find_by_insee_code(@item.main_town_insee_code) if @item.main_town_insee_code
    flash.now[:alert] ||= "Une erreur est survenue lors de la mise à jour de l'offre."
    render :edit
  end

  def destroy
    if ProgramItem.where(reference: @item.reference).destroy_all
      redirect_to moderator_program_items_url, notice: "L'offre a bien été supprimée."
    else
      flash.now[:alert] = "Une erreur est survenue lors de la suppression de l'offre."
      render :index
    end
  end

  def confirm
  end

  def account
    @items = []
    unless params[:user_id].blank?
      @user = User.find(params[:user_id])
      @items = ProgramItem.active_versions.visible.where(user_id: params[:user_id])
    end
  end

  def entity
    @items = []
    unless params[:entity_id].blank?
      @entity = LegalEntity.find(params[:entity_id])
      @items = ProgramItem.active_versions.visible.where(user_id: User.where(legal_entity_id: params[:entity_id]).collect {|u| u.id})
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

  private

  def item_params
    params.require(:program_item).permit!
  end

  def set_program_item
    @item = ProgramItem.find(params[:id])
    @item.author = current_moderator.first_name
    @item.set_openings
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
