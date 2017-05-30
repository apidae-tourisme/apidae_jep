class AddActiveToModerators < ActiveRecord::Migration
  def change
    add_column :moderators, :active, :boolean
  end
end
