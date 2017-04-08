class UpdateLegalEntitiesIndex < ActiveRecord::Migration
  def change
    remove_index :legal_entities, :name
    add_index :legal_entities, :name, unique: false
  end
end
