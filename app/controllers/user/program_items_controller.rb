class User::ProgramItemsController < User::UserController
  before_action :set_program
  before_action :set_program_item, only: [:edit, :update, :destroy]

  def new
    @item = ProgramItem.new(program_id: @program.id)
  end

  def create
    @item = ProgramItem.new(item_params)
    @item.save
  end

  def edit
  end

  def update
    @item.update(item_params)
  end

  def destroy
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
end
