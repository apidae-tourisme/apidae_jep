class AddColumnsToModerators < ActiveRecord::Migration
  def change
    add_column :moderators, :first_name, :string
    add_column :moderators, :last_name, :string
    add_column :moderators, :telephone, :string
    add_column :moderators, :role, :string
    add_column :moderators, :apidae_data, :text
    add_column :moderators, :notification_email, :string
    add_column :moderators, :member_ref, :string
  end
end
