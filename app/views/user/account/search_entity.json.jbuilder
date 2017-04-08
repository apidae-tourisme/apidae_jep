json.results do
  json.array!(@entities.each_with_index.to_a) do |(entity, index)|
    json.extract! entity, :id, :town, :postal_code, :phone, :email, :website
    json.text entity.name
    json.address entity.adresse1
    json.is_first true if index == 0
  end
end