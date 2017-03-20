class CreateProgramItems < ActiveRecord::Migration
  def change
    create_table :program_items do |t|
      t.integer :program_id
      t.integer :external_id
      t.integer :rev
      t.string :title
      t.text :description
      t.text :details
      t.string :status
      t.text :desc_data
      t.text :location_data
      t.text :rates_data
      t.text :opening_data
      t.text :contact_data

      t.timestamps null: false
    end
  end
end
