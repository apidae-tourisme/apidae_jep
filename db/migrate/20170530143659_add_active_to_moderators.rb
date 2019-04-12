class AddActiveToModerators < ActiveRecord::Migration[4.2]
  def change
    add_column :moderators, :active, :boolean
  end
end
