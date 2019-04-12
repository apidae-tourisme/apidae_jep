class AddSummaryToProgramItems < ActiveRecord::Migration[4.2]
  def change
    add_column :program_items, :summary, :text
  end
end
