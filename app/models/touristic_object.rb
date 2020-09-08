class TouristicObject

  attr_reader :illustrations

  def to_program_item
    ProgramItem.new(
        rev: 1,
        ordering: 1,
        status: ProgramItem::STATUS_DRAFT,
        external_id: id,
        item_type: ITEM_VISITE,
        title: title,
        description: description,
        main_place: information[:nomLieu],
        main_lat: lat,
        main_lng: lng,
        main_address: address_details[:adresse1],
        main_town_insee_code: retrieve_insee_code(address_details[:commune][:nom]),
        main_transports: public_transports_info,
        free: @descriptionTarif && @descriptionTarif[:gratuit],
        rates_desc: tarif,
        booking: booking,
        booking_details: reservation,
        booking_telephone: booking_contact([PHONE])['Téléphone'],
        booking_email: booking_contact([EMAIL])['Mél'],
        booking_website: booking_contact([WEBSITE])['Site web (URL)'],
        telephone: contact([PHONE])['Téléphone'],
        email: contact([EMAIL])['Mél'],
        website: contact([WEBSITE])['Site web (URL)']
    )
  end

  def updated_at
    Time.parse(@gestion[:dateModification]) unless @gestion.blank? || @gestion[:dateModification].blank?
  end

  def retrieve_insee_code(town_name)
    matched_town = Town.where(name: town_name).first
    matched_town.insee_code if matched_town
  end

  def public_transports_info
    @localisation[:geolocalisation][:complement][@libelle] if @localisation && @localisation[:geolocalisation] && @localisation[:geolocalisation][:complement]
  end

  def lat
    val = nil
    geoloc_details = @localisation[:geolocalisation]
    if geoloc_details && geoloc_details[:valide]
      if geoloc_details[:geoJson] && geoloc_details[:geoJson][:coordinates] && geoloc_details[:geoJson][:coordinates].length == 2
        val = geoloc_details[:geoJson][:coordinates][1]
      end
    end
    val
  end

  def lng
    val = nil
    geoloc_details = @localisation[:geolocalisation]
    if geoloc_details && geoloc_details[:valide]
      if geoloc_details[:geoJson] && geoloc_details[:geoJson][:coordinates] && geoloc_details[:geoJson][:coordinates].length == 2
        val = geoloc_details[:geoJson][:coordinates][0]
      end
    end
    val
  end

  def booking
    @reservation && @reservation[:organismes] && @reservation[:organismes].length > 0
  end

  def booking_contact(types_ids = [])
    contact_details = {}
    if booking
      contact_entries = @reservation[:organismes].first[:moyensCommunication] || []
      contact_entries.each do |c|
        if types_ids.include?(c[:type][:id])
          label = c[:type][@libelle]
          contact_details[label] = c[:coordonnees][:fr]
        end
      end
    end
    contact_details
  end

  def openings
    @ouverture.blank? ? [] : @ouverture[:periodesOuvertures]
  end

  def openings_description
    @ouverture[:periodeEnClair][:libelleFr] unless @ouverture.blank? || @ouverture[:periodeEnClair].blank?
  end
end