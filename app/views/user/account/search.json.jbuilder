json.users do
  json.array!(@users) do |user|
    json.text user.full_name_with_entity(true)
    if user.legal_entity
      json.legal_entity "#{user.legal_entity.label} - Identifiant Apidae : #{user.legal_entity.external_id}"
      json.telephone user.legal_entity.phone
      json.email user.legal_entity.email
      json.website user.legal_entity.website
      json.id user.id
    end
  end
end
