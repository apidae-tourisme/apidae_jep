class AddReferenceToProgramItems < ActiveRecord::Migration
  def change
    add_column :program_items, :reference, :integer

    add_index :program_items, :reference, unique: false
  end
end
