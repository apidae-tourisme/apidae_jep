class Moderator::ProgramsController < Moderator::ModeratorController
  before_action :set_program, only: [:edit, :update, :destroy]

  def index
    @programs = Program.all
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
