class AddExternalIdToLegalEntities < ActiveRecord::Migration
  def change
    add_column :legal_entities, :external_id, :integer
  end
end
