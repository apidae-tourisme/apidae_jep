class CreateLegalEntities < ActiveRecord::Migration[4.2]
  def change
    create_table :legal_entities do |t|
      t.string :name
      t.string :email
      t.text :address
      t.string :postal_code
      t.string :town
      t.string :website
      t.string :phone

      t.timestamps null: false
    end

    add_index :legal_entities, :name, unique: true
    add_index :legal_entities, :postal_code, unique: false
    add_index :legal_entities, :town, unique: false
  end
end
