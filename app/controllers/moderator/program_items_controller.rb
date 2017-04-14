#encoding: UTF-8

class Moderator::ProgramItemsController < Moderator::ModeratorController
  before_action :set_program
  before_action :set_program_item, only: [:edit, :update, :destroy, :confirm, :reorder, :select_program, :save_program]

  def edit
    if @item.user.legal_entity.external_id.nil?
      redirect_to edit_moderator_account_url(@item.user, validate: true), notice: "Validation de la structure organisatrice requise"
    end
  end

  def update
    begin
      if @item.update(item_params)
        if @item.validated? && @item.remote_save
          redirect_to edit_moderator_program_url(@item.program), notice: "L'offre a bien été enregistrée." and return
        else
          redirect_to edit_moderator_program_url(@item.program), notice: "L'offre a bien été mise à jour." and return
        end
      end
    rescue OAuth2::Error => e
      Raven.capture_exception(e)
      if e.response.parsed
        logger.error "Apidae error : #{e.response.parsed['errorType']} - #{e.response.parsed['message']} - item : #{@item.id}"
        error_msg = e.response.parsed['message']
        error_msg = error_msg.split("\n").first if errort_msg && error_msg.include?("\n")
        flash.now[:alert] = "Une erreur s'est produite au cours de l'enregistrement dans la base " +
            "de données Apidae.\nLe message fourni est le suivant : #{error_msg}"
      else
        logger.error "Apidae error : #{e.response} - item : #{@item.id}"
        flash.now[:alert] = "Une erreur s'est produite au cours de l'enregistrement dans la base de données Apidae."
      end
    end
    render :edit, notice: "Une erreur est survenue lors de la mise à jour de l'offre."
  end

  def destroy
  end

  def confirm
  end

  def reorder
    unless params[:direction].blank?
      ProgramItem.change_order(@item, params[:direction])
    end
    redirect_to edit_moderator_program_url(@program), notice: "L'offre a bien été mise à jour."
  end

  def select_program
    @programs = @program.users.collect {|u| u.programs}.flatten.uniq.collect {|p| [p.title, p.id]}
  end

  def save_program
    if @item.update(item_params)
      redirect_to edit_moderator_program_url(@item.program), notice: "L'offre a bien déplacée dans sa nouvelle programmation."
    else
      redirect_to edit_moderator_program_url(@program), notice: "Une erreur est survenue au cours du déplacement de l'offre."
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

  def set_program
    @program = Program.find(params[:program_id])
  end

  def set_program_item
    @item = ProgramItem.find(params[:id])
    @item.author = current_moderator.first_name
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
