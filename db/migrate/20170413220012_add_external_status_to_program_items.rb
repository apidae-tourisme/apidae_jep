class AddExternalStatusToProgramItems < ActiveRecord::Migration
  def change
    add_column :program_items, :external_status, :string
  end
end
