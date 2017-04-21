class CreateCommunicationPolls < ActiveRecord::Migration
  def change
    create_table :communication_polls do |t|
      t.string :first_name
      t.string :last_name
      t.string :role
      t.string :town_insee_code
      t.string :phone
      t.string :email
      t.string :delivery_address
      t.string :delivery_insee_code
      t.text :communication_data

      t.timestamps null: false
    end
  end
end
