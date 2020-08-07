json.type "FeatureCollection"
json.features do
  json.array!(@entities) do |e|
    json.properties do
      json.id e.id
      json.name e.name
      json.label e.name
      json.street e.street_address
      json.telephone e.phone
      json.email e.email
      json.website e.website
      json.layer 'venue'
      if e.town
        json.postalcode_gid "X:X:#{e.town.insee_code}"
        json.locality e.town.label
      end
    end
    json.geometry do
      json.coordinates [e.longitude, e.latitude]
    end
  end
end


