class Moderator::ProgramItemsController < Moderator::ModeratorController
  before_action :set_program
  before_action :set_program_item, only: [:edit, :update, :destroy, :confirm, :reorder, :select_program, :save_program]

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to confirm_moderator_program_program_item_url(@program.id, @item)
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
