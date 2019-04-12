class AddIndexToTowns < ActiveRecord::Migration[4.2]
  def change
    add_index :towns, :insee_code, unique: true
  end
end
