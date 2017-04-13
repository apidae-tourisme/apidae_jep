class AddUserIdToProgramItems < ActiveRecord::Migration
  def change
    add_column :program_items, :user_id, :integer
  end
end
