class AddIndexToTowns < ActiveRecord::Migration
  def change
    add_index :towns, :insee_code, unique: true
  end
end
