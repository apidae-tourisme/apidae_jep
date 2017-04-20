class AddDescriptionToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :desc_data, :text
  end
end
