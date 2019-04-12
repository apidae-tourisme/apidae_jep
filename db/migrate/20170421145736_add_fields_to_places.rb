class AddFieldsToPlaces < ActiveRecord::Migration[4.2]
  def change
    add_column :places, :uid, :uuid
    add_column :places, :country, :string
    add_index :places, :uid, unique: true
  end
end
