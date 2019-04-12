class AddUserIdToCommunicationPolls < ActiveRecord::Migration[4.2]
  def change
    add_column :communication_polls, :user_id, :integer
  end
end
