json.towns do
  json.array!(@towns) do |town|
    json.text "#{town.name} (#{town.postal_code})"
    json.id town.insee_code
  end
end
