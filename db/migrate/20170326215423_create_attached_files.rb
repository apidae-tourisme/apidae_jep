class CreateAttachedFiles < ActiveRecord::Migration
  def change
    create_table :attached_files do |t|
      t.integer :program_item_id
      t.attachment :picture
      t.text :data
      t.timestamps null: false
    end
  end
end
