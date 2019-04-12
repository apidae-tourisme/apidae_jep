class AddItemTypeToProgramItems < ActiveRecord::Migration[4.2]
  def change
    add_column :program_items, :item_type, :string
  end
end
