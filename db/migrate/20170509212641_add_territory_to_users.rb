class AddTerritoryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :territory, :string
    add_index :users, :territory, unique: false
  end
end
