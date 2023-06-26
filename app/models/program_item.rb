#encoding: UTF-8

require 'open-uri'
require 'events_importer'
require 'touristic_object'

class ProgramItem < ActiveRecord::Base
  include LoggableConcern
  include WritableConcern

  belongs_to :user

  has_many :item_openings, dependent: :destroy
  has_many :attached_files, dependent: :destroy

  accepts_nested_attributes_for :item_openings, allow_destroy: true
  accepts_nested_attributes_for :attached_files, allow_destroy: true, reject_if: proc {|attrs| attrs['picture'].blank? && attrs['picture_file_name'].blank? }

  attr_accessor :territory

  STATUS_DRAFT = 'draft'
  STATUS_PENDING = 'pending'
  STATUS_VALIDATING = 'validating'
  STATUS_VALIDATED = 'validated'
  STATUS_REJECTED = 'rejected'
  STATUS_APIDAE_ERROR = 'apidae_error'

  DIRECTION_UP = 'up'
  DIRECTION_DOWN = 'down'

  store :desc_data, accessors: [:place_desc, :place_desc_ref, :event_planners, :building_ages, :building_types, :accessibility,
                                :audience, :criteria, :themes, :validation_criteria, :accept_pictures, :accept_safety, :covid_desc], coder: JSON
  store :location_data, accessors: [:main_place, :main_lat, :main_lng, :main_address, :main_town_insee_code,
                                    :main_transports, :alt_place, :alt_lat, :alt_lng, :alt_address,
                                    :alt_town_insee_code, :alt_postal_code, :alt_transports], coder: JSON
  store :rates_data, accessors: [:free, :rates_desc, :booking, :booking_details, :booking_telephone, :booking_email, :booking_website], coder: JSON
  store :opening_data, accessors: [:openings_desc, :openings, :openings_text, :openings_details], coder: JSON
  store :contact_data, accessors: [:telephone, :email, :website], coder: JSON

  validates_presence_of :item_type, :title, :main_place, :main_lat, :main_lng, :main_address, :main_town_insee_code,
                        :main_transports, :summary, :accessibility
  validates :accept_pictures, acceptance: true
  validates :accept_safety, acceptance: true
  validates_length_of :summary, maximum: 255
  validate :openings_presence

  def self.new_default(usr)
    item = new(item_type: ITEM_VISITE, free: true, booking: false, accept_pictures: '0', user_id: (usr.id if usr), rev: 1,
        status: ProgramItem::STATUS_DRAFT, openings: {})
    if usr && usr.legal_entity
      item.telephone = usr.legal_entity.phone
      item.email = usr.legal_entity.email
      item.website = usr.legal_entity.website
    end
    item
  end

  def self.build_from(prev_item)
    item = prev_item.dup
    item.status = ProgramItem::STATUS_DRAFT
    item.external_status = nil
    item.rev += 1
    item.reference = prev_item.reference
    prev_item.attached_files.each do |f|
      item.attached_files << AttachedFile.new(program_item: item, data: f.data, picture: f.picture, created_at: f.created_at)
    end
    item.load_remote_openings
    # item.openings.each_pair do |d, o|
    #   o['id'] = "#{item.external_ref}-#{d.gsub('-', '')}"
    # end
    item
  end

  def self.set_openings_details(items)
    items.each_slice(25) do |items_batch|
      items_batch.each do |item|
        item.openings_details ||= []
      end
      ids = items_batch.map {|item| item.openings.select {|k, v| !v.blank?}.values.flatten}.flatten.uniq.map {|op_id| op_id.to_s}
      apidate_url = Rails.application.config.apidate_api_url + '/apidae_period'
      logger.info "Retrieve openings : #{apidate_url}?ids=#{CGI.escape('["' + ids.join('","') + '"]')}"
      begin
        response = ''
        open(apidate_url + '?ids=' + CGI.escape('["' + ids.join('","') + '"]')) { |f|
          f.each_line {|line| response += line if line}
        }
        ops = JSON.parse(response)
        ops.each do |opening|
          ext_id = opening['externalRef']
          item = items_batch.find {|item| item.external_id && item.external_id.to_s == ext_id.to_s}
          if item
            item.openings_details << opening
          end
        end
      rescue OpenURI::HTTPError => e
        logger.error "Could not retrieve openings details"
        raise
      end
    end
  end

  def last_revision
    ProgramItem.where(reference: reference).order(:rev).last
  end

  def openings_presence
    if openings.blank? || openings.values.all? {|v| v.blank?}
      errors.add('openings', 'missing')
    end
  end

  def picture
    attached_files.first.picture.url if attached_files.any?
  end

  def pending?
    status == STATUS_PENDING
  end

  def validated?
    status == STATUS_VALIDATED
  end

  def rejected?
    status == STATUS_REJECTED
  end

  def draft?
    status == STATUS_DRAFT
  end

  def new_item?
    !persisted? && rev == 1
  end

  def structure
    user.legal_entity.name if user && user.legal_entity
  end

  def town
    Town.find_by_insee_code(main_town_insee_code).label if Town.find_by_insee_code(main_town_insee_code)
  end

  def open_dates
    openings.blank? ? [] : openings.select {|k, v| !v.blank? && !v.to_s.include?('-') && openings_details.map {|od| od['startDate']}.include?(k)}.keys
  end

  def validated_at
    if validated?
      updated_at
    elsif rev > 1
      last_validation = ProgramItem.where(reference: reference, status: STATUS_VALIDATED).order(:rev).last
      last_validation ? last_validation.updated_at : nil
    end
  end

  def self.active_versions
    active_ids = select("MAX(id) AS id").group(:reference)
    where(id: active_ids)
  end

  def self.visible
    where(status: [STATUS_PENDING, STATUS_VALIDATED, STATUS_REJECTED])
  end

  def self.in_status(territory, year, *statuses)
    # Note : specific cases - switch from GL to Isere
    switched_codes = ['38446', '73092', '26270', '69064', '69007', '69097', '69119', '69189', '69193', '69235', '69118', '69080', '69236']
    active_versions.where(created_at: (Date.new(year, 1, 1)..Date.new(year + 1, 1, 1)))
        .joins("LEFT JOIN users ON users.id = program_items.user_id")
        .where("program_items.status IN (?)", statuses)
        .where("program_items.user_id IS NULL OR (users.territory = ? #{territory == ISERE ? 'OR' : 'AND'} location_data::json->>'main_town_insee_code' #{'NOT' unless territory == ISERE} IN (?))", territory, switched_codes)
  end

  def self.validated
    where(status: STATUS_VALIDATED)
  end

  def self.draft
    where(status: STATUS_DRAFT)
  end

  def self.rejected
    where(status: STATUS_REJECTED)
  end

  def set_territory(member_ref)
    if member_ref == ISERE
      t = TERRITORIES[ISERE].find {|k, v| v.include?(main_town_insee_code)}
      self.territory = t.first if t
    else
      self.territory = TERRITORIES_BY_CODE[member_ref][Town.find_by_insee_code(main_town_insee_code).postal_code] if Town.find_by_insee_code(main_town_insee_code)
    end
  end

  def load_remote_openings
    if external_id
      obj = EventsImporter.load_apidae_events([external_id], 'id', 'ouverture')
      if obj && obj.openings
        openings.transform_values! {|v| v.is_a?(Hash) ? v : {'id' => v}}
        openings.each_pair do |d, op|
          obj_opening = obj.openings.find {|o| o[:dateDebut] == d && o[:dateFin] == d}
          if obj_opening
            op['id'] = obj_opening[:identifiantTechnique]
          end
        end
      end
    end
  end

  def self.set_openings_texts(items)
    remote_ids = items.map {|i| i.external_id}.select {|ext_id| !ext_id.blank?}.uniq
    Rails.logger.info "Set openings texts on #{remote_ids.count} remote ids"
    objs = EventsImporter.load_apidae_events(remote_ids, 'id', 'ouverture')
    items.each do |item|
      item.openings_text = nil
      unless item.external_id.blank?
        obj = objs.is_a?(Array) ? objs.find {|o| o.id.to_i == item.external_id} : objs
        item.openings_text = obj.openings_description if obj
      end
    end
  end

  def external_ref
    external_id || "JEP-#{(Time.current.to_f * 1000).floor}"
  end

  def editable?
    created_at.nil? || created_at >= Date.new(EDITION, 1, 1)
  end

  def opening_id(ref, date)
    openings.dig(date, 'id').blank? ? "#{ref}-#{date.gsub('-', '')}" : openings.dig(date, 'id')
  end

  def remote_save
    if external_id
      obj = EventsImporter.load_apidae_events([external_id], 'id')
      if obj.nil?
        logger.info("Removing obsolete Apidae reference #{external_id}")
        self.external_id = nil
      end
    end

    form_data = build_multipart_form(merge_data)
    response = save_to_apidae(user.territory, form_data, :api_url, :put)

    if external_id || (response['id'] && update_attributes!(external_id: response['id'], external_status: response['status']))
      update_apidae_criteria(user.territory, build_criteria((themes || []) + (criteria || []) + (validation_criteria || [])))
      # bind_openings if rev == 1
      # touch_remote_obj
    end
  end

  def merge_data
    merged = {}

    unless location_data.nil? || location_data.empty?
      place_town = Town.find_by_insee_code(main_town_insee_code)
      merged[:place] = {
          name: main_place, startingPoint: alt_place, address: main_address,
          postal_code: place_town.postal_code, latitude: main_lat, longitude: main_lng,
          extraInfo: main_transports, external_id: place_town.external_id
      }
    end

    unless desc_data.nil? || desc_data.empty?
      merged[:description] = {
          name: title,
          shortDescription: summary,
          longDescription: description,
          covidDescription: covid_desc,
          cultureDescription: place_desc,
          planners: event_planners,
          accessibility: accessibility,
          audience: themes,
          categories: (criteria || []) + (validation_criteria || []),
          themes: (themes || []) + (criteria || []) + (validation_criteria || [])
      }
    end

    merged[:legal_entity] = {external_id: user.legal_entity.external_id}

    unless contact_data.nil? || contact_data.empty?
      merged[:contact] = {
          phone: telephone, email: email, website: website
      }
    end

    unless rates_data.nil? || rates_data.empty?
      merged[:rates] = {
          free: (free == 'true' || free == true), description: rates_desc
      }
      merged[:booking] = {
          booking: (booking == 'true' || booking == true), bookingDetails: booking_details,
          bookingPhone: booking_telephone, bookingEmail: booking_email, bookingWebsite: booking_website
      }
    end

    merged[:openings] = openings

    merged
  end

  def build_multipart_form(data_hash)
    form_data = {
        mode: external_id ? WritableConcern::UPDATE : WritableConcern::CREATE,
        id: (external_id if external_id),
        type: 'FETE_ET_MANIFESTATION',
        skipValidation: 'true'
    }

    form_data[:expiration] = {dateExpiration: (Date.parse(openings.keys.sort.last) + 1.day).to_s, expirationAction: "MASQUER_AUTOMATIQUEMENT"} unless openings.blank?
    form_data[:fields] = '["root"]'
    form_data[:root] ||= '{"type":"FETE_ET_MANIFESTATION"}'
    form_data['root.fieldList'] = '[]'

    data_hash.each_pair do |k, v|
      converted_data = build_form_data(k, v)
      unless converted_data.empty?
        merged_data = safe_merge(extract_as_hash(form_data[:root]), converted_data)
        form_data[:root] = JSON.generate(merged_data)
        impacted_fields = data_fields(converted_data, Array.new)
        form_data['root.fieldList'] = merge_fields(form_data['root.fieldList'], impacted_fields)
      end
    end

    attachments = {}
    attached_files.each_with_index do |attachment, i|
      attachment_key = "attachment-#{i}"
      if attachment.picture
        attachments[:illustrations] ||= []
        form_data["multimedia.#{attachment_key}"] = Faraday::UploadIO.new(attachment.picture.path(:xlarge), attachment.picture_content_type)
        attachments[:illustrations] << {
            link: false,
            type: 'IMAGE',
            traductionFichiers: [{locale: 'fr', url: "MULTIMEDIA##{attachment_key}"}],
            nom: {libelleFr: attachment.picture_file_name},
            copyright: {libelleFr: attachment.credits}
        }
      end
    end

    if attachments.any?
      merged_data = safe_merge(extract_as_hash(form_data[:root]), attachments)
      form_data[:root] = JSON.generate(merged_data)
      form_data['root.fieldList'] = merge_fields(form_data['root.fieldList'], ['illustrations'])
    end

    form_data
  end

  def update_apidae_criteria(member_ref, criteria_data)
    if criteria_data[:added].length > 0
      form_data = {criteres: JSON.generate({id: [external_id], criteresInternesAAjouter: criteria_data[:added]})}
      save_to_apidae(member_ref, form_data, :criteria_url, :put)
    end
    if criteria_data[:removed].length > 0
      form_data = {criteres: JSON.generate({id: [external_id], criteresInternesASupprimer: criteria_data[:removed]})}
      save_to_apidae(member_ref, form_data, :criteria_url, :delete)
    end
  end

  def format_openings(openings = [])
    openings.collect {|o| o.as_text}.join("\n")
  end

  def attached_pictures
    attached_files.collect { |a| "/pictures/#{user_id}/#{a.picture_file_name}" }
  end

  def about
    "Saisie effectuée le #{I18n.l(created_at, format: :detailed)} par #{user.full_name} (#{user.email} - #{user.telephone || 'Téléphone non communiqué'})\n" +
        "Structure organisatrice : #{user.legal_entity.name} (#{user.legal_entity.external_id.nil? ? 'Nouvelle structure' : ('Identifiant Apidae : ' + user.legal_entity.external_id.to_s)})"
  end

  def bind_openings
    try = 1
    obj = nil
    while obj.nil? && try < 5
      sleep(2)
      logger.debug "Retrieving obj #{external_id} - try #{try}..."
      obj = EventsImporter.load_apidae_events([external_id], 'id', 'ouverture')
      try += 1
    end
    if obj
      openings_map = {}
      obj.openings.each do |o|
        if o[:dateDebut] == o[:dateFin] && !openings[o[:dateDebut]].blank?
          openings_map[o[:identifiantTechnique]] = openings[o[:dateDebut]]
        end
      end
      update_remote_ids(openings_map, false)
    else
      logger.error "Remote object not found : #{external_id}"
    end
  end

  def update_remote_ids(openings_map, dry_run)
    openings_map.each_pair do |remote_id, local_id|
      logger.debug "Offer #{id} - Binding local period id #{local_id} to apidae period #{remote_id}"
      unless dry_run
        DeliveryBoy.deliver('{"operation":"UPDATE_PERIOD","sourceId":"' + local_id.to_s + '","payload":{"externalId":"' + remote_id.to_s + '","externalRef":"' + external_id.to_s + '"}}',
                              topic: 'apidae_period')
      end
    end
  end

  def touch_remote_obj
    logger.debug "Touching obj #{external_id} to refresh openings text"
    sleep(5)
    form_data = {
        mode: WritableConcern::UPDATE,
        id: external_id,
        type: 'FETE_ET_MANIFESTATION',
        skipValidation: 'true'
    }
    form_data[:fields] = '["root"]'
    form_data[:root] ||= '{"type":"FETE_ET_MANIFESTATION"}'
    form_data['root.fieldList'] = '[]'

    openings_data = {
        ouverture: {
            periodeEnClairGenerationMode: 'AUTOMATIQUE'
        }
    }
    merged_data = safe_merge(extract_as_hash(form_data[:root]), openings_data)
    form_data[:root] = JSON.generate(merged_data)
    impacted_fields = data_fields(openings_data, Array.new)
    form_data['root.fieldList'] = merge_fields(form_data['root.fieldList'], impacted_fields)

    save_to_apidae(user.territory, form_data, :api_url, :put)

    sleep(5)

    set_openings(true)
  end

  def apidate_openings
    ops = nil
    unless external_id.blank?
      apidate_url = Rails.application.config.apidate_api_url + '/apidae_period'
      logger.info "Retrieve openings : #{apidate_url}?ref=#{CGI.escape('"' + external_id.to_s + '"')}"
      begin
        response = ''
        open(apidate_url + '?ref=' + CGI.escape('"' + external_id.to_s + '"')) { |f|
          f.each_line {|line| response += line if line}
        }
        ops = JSON.parse(response)
      rescue OpenURI::HTTPError => e
        if e.message && e.message.include?("404")
          logger.error "No openings for ref #{external_id}"
        else
          raise
        end
      end
    end
    ops
  end

  private

  def build_form_data(key, value)
    case key
      when :place
        converted_hash = {
            localisation: {
                adresse: {
                    adresse1: value[:address],
                    codePostal: value[:postal_code],
                    etat: 'France',
                    commune: {id: value[:external_id]},
                    nomDuLieu: value[:startingPoint].blank? ? value[:name] : value[:startingPoint]
                },
                geolocalisation: {
                    valide: true,
                    complement: {libelleFr: value[:extraInfo]},
                    geoJson: {
                        type: 'Point',
                        coordinates: [value[:longitude], value[:latitude]]
                    }
                }
            },
            informationsFeteEtManifestation: {
                nomLieu: value[:name]
            }
        }
      when :description
        converted_hash = {
            nom: {libelleFr: value[:name]},
            localisation: {
                environnements: build_environments(value[:categories])
            },
            presentation: {
                descriptifCourt: {libelleFr: value[:shortDescription]},
                descriptifDetaille: {libelleFr: value[:longDescription]},
                typologiesPromoSitra: build_typologies(value[:themes]),
                descriptifsThematises: build_theme_descs(value)
            },
            prestations: {
                tourismesAdaptes: accessibility_values(value[:accessibility]),
                typesClientele: audience_values(value[:audience])
            },
            informationsFeteEtManifestation: {
                categories: build_categories(value[:categories]),
                themes: build_themes(value[:themes]),
                portee: {id: 2351, elementReferenceType: 'FeteEtManifestationPortee'},
                evenementGenerique: {id: 2388, elementReferenceType: 'FeteEtManifestationGenerique'},
                typesManifestation: [{id: 1958, elementReferenceType: 'FeteEtManifestationType'}],
            }
        }
      when :legal_entity
        converted_hash = {
            informations: {
                structureGestion: {
                    id: value[:external_id],
                    type: 'STRUCTURE'
                }
            }
        }
      when :contact
        converted_hash = {
            informations: {
                moyensCommunication: contact_info(value)
            }
        }
      when :rates
        converted_hash = {
            descriptionTarif: {
                indicationTarif: value[:free] ? 'GRATUIT' : 'PAYANT',
                gratuit: value[:free],
                tarifsEnClair: {libelleFr: value[:description]},
                tarifsEnClairGenerationMode: value[:free] ? 'AUTOMATIQUE' : 'MANUEL'
            }
        }
      when :openings
        converted_hash = {
            ouverture: {
                periodeEnClair: {libelleFr: ''},
                periodeEnClairGenerationMode: 'AUTOMATIQUE',
                periodesOuvertures: opening_times(value)
            }
        }
      when :booking
        converted_hash = build_booking_data(value)
      else
        converted_hash = {}
    end
    converted_hash
  end

  def accessibility_values(data = [])
    values = []

    if data.include?('deaf_people')
      values << {id: 1191, elementReferenceType: 'TourismeAdapte'}
    end
    if data.include?('blind_people')
      values << {id: 1199, elementReferenceType: 'TourismeAdapte'}
    end
    if data.include?('fully_accessible')
      values << {id: 3653, elementReferenceType: 'TourismeAdapte'}
    end
    if data.include?('partly_accessible')
      values << {id: 3652, elementReferenceType: 'TourismeAdapte'}
    end
    if data.include?('not_accessible')
      values << {id: 3651, elementReferenceType: 'TourismeAdapte'}
    end
    values
  end

  def audience_values(data = [])
    values = []
    family_refs = ["En famille", "Famille"].map(&:parameterize)
    if (data & family_refs).any?
      values << {id: 513, elementReferenceType: 'TypeClientele'}
    end
    values << {id: 594, elementReferenceType: 'TypeClientele'} if data.include?("Réservé aux enfants".parameterize)
    values << {id: 496, elementReferenceType: 'TypeClientele'} if data.include?("Jeunes (15-25 ans)".parameterize)
    values
  end

  def build_categories(values = [])
    categories = []
    cat_values = (values || []) + [item_type]
    APIDAE_CATEGORIES.each_pair do |cat, id|
      categories << {id: id, elementReferenceType: 'FeteEtManifestationCategorie'} if cat_values.include?(cat.parameterize)
    end
    categories
  end

  def build_themes(values = [])
    themes = []
    unless values.nil?
      APIDAE_THEMES.each_pair do |th, id|
        themes << {id: id, elementReferenceType: 'FeteEtManifestationTheme'} if values.include?(th.parameterize)
      end
    end
    themes
  end

  def build_theme_descs(value)
    theme_descs = []
    # theme_descs << {theme: {elementReferenceType: "DescriptifTheme", id: APIDAE_COVID_DESC}, description: {libelleFr: value[:covidDescription]}} unless value[:covidDescription].blank?
    theme_descs << {theme: {elementReferenceType: "DescriptifTheme", id: APIDAE_HISTORY_DESC}, description: {libelleFr: value[:cultureDescription]}} unless value[:cultureDescription].blank?
    theme_descs
  end

  def build_typologies(values = [])
    typologies = []
    unless values.nil?
      APIDAE_TYPOLOGIES.each_pair do |typo, id|
        typologies << {id: id, elementReferenceType: 'TypologiePromoSitra'} if values.include?(typo.parameterize)
      end
    end
    typologies
  end

  def build_environments(values = [])
    environments = []
    unless values.nil?
      APIDAE_ENVIRONMENTS.each_pair do |env, id|
        environments << {id: id, elementReferenceType: 'Environnement'} if values.include?(env.parameterize)
      end
    end
    environments
  end

  def build_booking_data(data_hash = {})
    result = {}
    if data_hash[:booking]
      booking_data = {}
      booking_data[:organismes] = [{
          structureReference: {
              id: user.legal_entity.external_id,
              type: 'STRUCTURE'
          },
          # Note : reservation directe par defaut (type obligatoire)
          type: {
              elementReferenceType: 'ReservationType',
              id: 475
          },
          moyensCommunication: []
                                   }]
      unless data_hash[:bookingPhone].blank?
        booking_data[:organismes][0][:moyensCommunication] <<
            {type: {id: 201, elementReferenceType: 'MoyenCommunicationType'}, coordonnees: {fr: data_hash[:bookingPhone]}}
      end
      unless data_hash[:bookingEmail].blank?
        booking_data[:organismes][0][:moyensCommunication] <<
            {type: {id: 204, elementReferenceType: 'MoyenCommunicationType'}, coordonnees: {fr: data_hash[:bookingEmail]}}
      end
      unless data_hash[:bookingWebsite].blank?
        booking_data[:organismes][0][:moyensCommunication] <<
            {type: {id: 205, elementReferenceType: 'MoyenCommunicationType'}, coordonnees: {fr: data_hash[:bookingWebsite]}}
      end
      booking_data[:complement] = {libelleFr: (data_hash[:booking] ? 'Réservation obligatoire' : 'Réservation recommandée')}
      booking_data[:complement][:libelleFr] += "\n#{data_hash[:bookingDetails]}" unless data_hash[:bookingDetails].blank?
      result[:reservation] = booking_data
    end
    result
  end

  def build_criteria(selected = [])
    input_refs = (selected || []) + [item_type]
    added = []
    APIDAE_CRITERIA.each_pair do |crit, id|
      added << id if input_refs.include?(crit.parameterize)
    end
    removed = APIDAE_CRITERIA.values - added
    {added: added, removed: removed}
  end

  # obj_opening = {
  #   "identifiant" => (!opening[:id].blank? && /^\d+$/.match?(opening[:id].to_s) ? opening[:id].to_i : nil),
  #   "dateDebut" => start_date,
  #   "dateFin" => end_date,
  #   "tousLesAns" => opening[:each_year]
  # }
  # if opening[:apihours].blank?
  #   obj_opening.merge!(week_days_openings(opening))
  #   tf = (!opening[:time_periods].blank? && opening[:time_periods].first && !opening[:time_periods].first[:time_frames].blank?) ?
  #          opening[:time_periods].first[:time_frames].first : nil
  #   if tf
  #     obj_opening["horaireOuverture"] = obj_time(tf[:start_time]) unless tf[:start_time].blank?
  #     obj_opening["horaireFermeture"] = obj_time(tf[:end_time]) unless tf[:end_time].blank?
  #   end
  # else
  #   time_periods = JSON.parse(opening[:apihours]).map {|tp| tp.except('description')}
  #   obj_opening['type'] = 'OUVERTURE_SAUF'
  #   obj_opening['timePeriods'] = time_periods
  # end
  #
  # obj_opening.merge!("identifiantTechnique" => opening[:external_id].to_i) if !opening[:external_id].blank? && /^\d+$/.match?(opening[:external_id].to_s)
  # obj_opening.merge!("complementHoraire" => opening[:details].transform_keys {|k| Apidae::ApidaeDataParser.localized_key(k.to_s).to_s}) unless opening[:details].blank?

  def opening_times(openings_data)
    opening_periods = []
    openings_data.each_pair do |date, op|
      unless op.blank? || op['value'].blank?
        time_periods = JSON.parse(op['value']).map {|tp| tp.except('description')}
        unless time_periods.blank?
          opening_period = {
              dateDebut: date,
              dateFin: date,
              type: 'OUVERTURE_SAUF',
              tousLesAns: false,
              timePeriods: time_periods
          }
          opening_period.merge!(identifiantTechnique: op['id'].to_i) if !op['id'].blank? && /^\d+$/.match?(op['id'].to_s)
          opening_period.merge!(complementHoraire: {libelleFr: openings_desc}) unless openings_desc.blank?
          opening_periods << opening_period
        end
      end
    end
    opening_periods
  end

  def apidate_opening(id)
    apidate_url = Rails.application.config.apidate_api_url + '/apidae_period'
    logger.info "Retrieve openings : #{apidate_url}?id=#{CGI.escape('"' + id.to_s + '"')}"
    op = nil
    begin
      response = ''
      open(apidate_url + '?id=' + CGI.escape('"' + id.to_s + '"')) { |f|
        f.each_line {|line| response += line if line}
      }
      op = JSON.parse(response)
    rescue OpenURI::HTTPError => e
      if e.message && e.message.include?("404")
        logger.info "Ignoring missing opening #{id}"
      else
        raise
      end
    end
    op
  end
end
