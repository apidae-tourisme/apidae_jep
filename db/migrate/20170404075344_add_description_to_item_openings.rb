class AddDescriptionToItemOpenings < ActiveRecord::Migration
  def change
    add_column :item_openings, :description, :text
  end
end
