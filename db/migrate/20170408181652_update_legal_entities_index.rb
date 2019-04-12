class UpdateLegalEntitiesIndex < ActiveRecord::Migration[4.2]
  def change
    remove_index :legal_entities, :name
    add_index :legal_entities, :name, unique: false
  end
end
