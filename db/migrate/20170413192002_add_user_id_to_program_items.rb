class AddUserIdToProgramItems < ActiveRecord::Migration[4.2]
  def change
    add_column :program_items, :user_id, :integer
  end
end
