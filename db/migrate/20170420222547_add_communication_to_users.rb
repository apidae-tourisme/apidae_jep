class AddCommunicationToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :communication, :boolean
  end
end
