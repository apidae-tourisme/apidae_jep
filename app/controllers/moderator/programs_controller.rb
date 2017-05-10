class Moderator::ProgramsController < Moderator::ModeratorController
  before_action :set_program, only: [:edit, :update, :destroy]

  def index
    @programs = Program.select(:id, :title, :updated_at).includes(:users)
                    .joins("JOIN program_items ON program_items.program_id = programs.id")
                    .where("program_items.status != '#{ProgramItem::STATUS_DRAFT}'")
                    .uniq
  end

  def edit
  end

  def update
    @program.update(program_params)
    redirect_to url_for(action: :edit), notice: 'La programmation a bien été mise à jour.'
  end

  def destroy
  end

  private

  def set_program
    @program = Program.find(params[:id])
  end

  def program_params
    params.require(:program).permit!
  end
end
