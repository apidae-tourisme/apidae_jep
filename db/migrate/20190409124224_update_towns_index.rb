class UpdateTownsIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :towns, :insee_code
    add_index :towns, :insee_code, unique: false
  end
end
