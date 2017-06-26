class AddSummaryToProgramItems < ActiveRecord::Migration
  def change
    add_column :program_items, :summary, :text
  end
end
