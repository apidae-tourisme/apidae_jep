class AddLegalEntityIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :legal_entity_id, :integer
  end
end
