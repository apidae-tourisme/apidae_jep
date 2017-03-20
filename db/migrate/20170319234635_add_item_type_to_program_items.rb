class AddItemTypeToProgramItems < ActiveRecord::Migration
  def change
    add_column :program_items, :item_type, :string
  end
end
