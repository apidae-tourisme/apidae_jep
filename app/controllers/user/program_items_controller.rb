class User::ProgramItemsController < User::UserController
  before_action :set_program

  def new
    @item = ProgramItem.new(program_id: @program.id)
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_program
    @program = Program.find(params[:program_id])
  end
end
