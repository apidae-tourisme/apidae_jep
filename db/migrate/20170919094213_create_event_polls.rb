class CreateEventPolls < ActiveRecord::Migration
  def change
    create_table :event_polls do |t|
      t.integer :user_id
      t.string :status
      t.text :event_data
      t.text :offers_data

      t.timestamps null: false
    end
  end
end
