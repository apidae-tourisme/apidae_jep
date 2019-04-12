class AddExternalStatusToProgramItems < ActiveRecord::Migration[4.2]
  def change
    add_column :program_items, :external_status, :string
  end
end
