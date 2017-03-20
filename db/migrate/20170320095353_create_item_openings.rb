class CreateItemOpenings < ActiveRecord::Migration
  def change
    create_table :item_openings do |t|
      t.integer :program_item_id
      t.string :type
      t.datetime :starts_at
      t.datetime :ends_at
      t.time :frequency
      t.time :duration

      t.timestamps null: false
    end
  end
end
