class AddLegalEntityIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :legal_entity_id, :integer
  end
end
