class CreateTowns < ActiveRecord::Migration
  def change
    create_table :towns do |t|
      t.string :name
      t.string :postal_code
      t.string :insee_code
      t.string :country
      t.string :territory
      t.integer :external_id

      t.timestamps null: false

      t.index :name, unique: false
      t.index :postal_code, unique: false
    end
  end
end
