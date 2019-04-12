class CreatePlaces < ActiveRecord::Migration[4.2]
  def change
    create_table :places do |t|
      t.string :name
      t.string :town_insee_code
      t.text :address_data
      t.float :latitude
      t.float :longitude
      t.float :altitude
      t.string :source
      t.text :access_data

      t.timestamps null: false
    end
  end
end
