class AddExternalIdToLegalEntities < ActiveRecord::Migration[4.2]
  def change
    add_column :legal_entities, :external_id, :integer
  end
end
