json.program_items do
  json.array!(@items) do |item|
    item_town = item_town(item.main_town_insee_code)
    json.id item.id
    json.reference item.reference
    json.revision item.rev
    json.user item.user ? item.user.full_name : 'unknown'
    json.entity item.user ? item.user.legal_entity.name : 'unknown'
    json.created_at item.created_at
    json.updated_at item.updated_at
    json.place do
      json.name item.main_place
      json.address item.main_address
      json.postal_code item_town ? item_town.postal_code : 'unknown'
      json.insee_code item.main_town_insee_code
      json.town item_town ? item_town.name : 'unknown'
      json.latitude item.main_lat
      json.longitude item.main_lng
      json.transports item.main_transports
      json.description item.place_desc
      json.starting_point item.alt_place
    end
    json.description do
      json.name item.title
      json.short_desc item.summary
      json.long_desc item.description
      json.accessibility normalize_list(item.accessibility) || []
      json.audience normalize_list(item.audience) || []
      json.planners item.event_planners
    end
    json.building do
      json.ages normalize_list(item.building_ages) || []
      json.types normalize_list(item.building_types) || []
    end
    json.themes normalize_list(item.themes) || []
    json.criteria normalize_list(item.criteria) || []
    json.validation_criteria normalize_list(item.validation_criteria) || []
    json.openings do
      json.values do
        json.array!(item.item_openings) do |o|
          json.starts_at o.starts_at
          json.ends_at o.ends_at
          json.duration o.duration
          json.frequency o.frequency
          json.description o.as_text
        end
      end
      json.description item.openings_desc
    end
    json.rates do
      json.free item.free
      json.description item.rates_desc
    end
    json.booking do
      json.enabled item.booking
      json.description item.booking_details
    end
    json.contact do
      json.phone item.telephone
      json.email item.email
      json.website item.website
      json.booking_phone item.booking_telephone
      json.booking_email item.booking_email
      json.booking_website item.booking_website
    end
    json.pictures do
      json.array!(item.attached_files) do |pic|
        json.name pic.picture_file_name
        json.url pic.picture_url
        json.credits pic.credits
      end
    end
  end
end
