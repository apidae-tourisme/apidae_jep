class AddOrderingToProgramItems < ActiveRecord::Migration
  def change
    add_column :program_items, :ordering, :integer
  end
end
