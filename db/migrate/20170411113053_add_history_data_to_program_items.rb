class AddHistoryDataToProgramItems < ActiveRecord::Migration[4.2]
  def change
    add_column :program_items, :history_data, :text
  end
end
