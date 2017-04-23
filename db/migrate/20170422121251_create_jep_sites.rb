class CreateJepSites < ActiveRecord::Migration
  def change
    create_table :jep_sites do |t|
      t.text :description
      t.text :site_data
      t.uuid :place_uid

      t.timestamps null: false

      t.index :place_uid, unique: true
    end
  end
end
