class AddStatusToLegalEntities < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_entities, :status, :string, default: 'active'
  end
end
