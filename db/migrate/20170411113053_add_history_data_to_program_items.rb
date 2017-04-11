class AddHistoryDataToProgramItems < ActiveRecord::Migration
  def change
    add_column :program_items, :history_data, :text
  end
end
