class User::ProgramsController < User::UserController
  before_action :set_program, only: [:edit, :update, :destroy]

  def create
    @program = Program.new
    @program.program_items.build(status: ProgramItem::STATUS_DRAFT)
    @program.save
    redirect_to url_for(action: :edit, id: @program.id), notice: 'La programmation a bien été créée.'
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_program
    @program = Program.find(params[:id])
  end
end
