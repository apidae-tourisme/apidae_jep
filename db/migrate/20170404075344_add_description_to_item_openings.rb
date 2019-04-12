class AddDescriptionToItemOpenings < ActiveRecord::Migration[4.2]
  def change
    add_column :item_openings, :description, :text
  end
end
