class AddGdprStatusToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :gdpr_status, :boolean
  end
end
