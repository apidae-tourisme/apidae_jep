class AddDescriptionToPlaces < ActiveRecord::Migration[4.2]
  def change
    add_column :places, :desc_data, :text
  end
end
