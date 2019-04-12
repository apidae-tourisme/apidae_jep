class AddOrderingToProgramItems < ActiveRecord::Migration[4.2]
  def change
    add_column :program_items, :ordering, :integer
  end
end
