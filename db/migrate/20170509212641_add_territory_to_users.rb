class AddTerritoryToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :territory, :string
    add_index :users, :territory, unique: false
  end
end
