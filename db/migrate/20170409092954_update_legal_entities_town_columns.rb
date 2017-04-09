class UpdateLegalEntitiesTownColumns < ActiveRecord::Migration
  def change
    remove_column :legal_entities, :town
    remove_column :legal_entities, :postal_code
    add_column :legal_entities, :town_insee_code, :string
  end
end
