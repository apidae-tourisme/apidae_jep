class AddUserIdToCommunicationPolls < ActiveRecord::Migration
  def change
    add_column :communication_polls, :user_id, :integer
  end
end
