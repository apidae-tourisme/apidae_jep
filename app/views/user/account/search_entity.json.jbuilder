json.results do
  json.array!(@entities.each_with_index.to_a) do |(entity, index)|
    json.extract! entity, :id, :phone, :email, :website, :town_insee_code, :external_id
    json.town_label entity.town.label if entity.town
    json.text entity.name
    json.address entity.adresse1
    json.is_first true if index == 0
  end
end