class User::ProgramsController < User::UserController
  before_action :set_program, only: [:edit, :update, :destroy]

  def new
    @program = Program.new
  end

  def create
    @program = Program.new(program_params)
    @program.users << current_user
    if @program.save
      redirect_to url_for(action: :edit, id: @program.id), notice: 'La programmation a bien été créée.'
    else
      render :new, notice: 'Une erreur est survenue lors de la création de la programmation.'
    end
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
