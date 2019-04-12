class ChangeOpeningsFieldsTypes < ActiveRecord::Migration[4.2]
  def change
    remove_column :item_openings, :duration
    remove_column :item_openings, :frequency
    add_column :item_openings, :duration, :integer
    add_column :item_openings, :frequency, :integer
  end
end
