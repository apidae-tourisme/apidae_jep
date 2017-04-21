class AddCommunicationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :communication, :boolean
  end
end
