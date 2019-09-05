#encoding: UTF-8

require 'open-uri'
require 'events_importer'
require 'touristic_object'
require 'kafka'

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
                                :audience, :criteria, :themes, :validation_criteria, :accept_pictures], coder: JSON
  store :location_data, accessors: [:main_place, :main_lat, :main_lng, :main_address, :main_town_insee_code,
                                    :main_transports, :alt_place, :alt_lat, :alt_lng, :alt_address,
                                    :alt_town_insee_code, :alt_postal_code, :alt_transports], coder: JSON
  store :rates_data, accessors: [:free, :rates_desc, :booking, :booking_details, :booking_telephone, :booking_email, :booking_website], coder: JSON
  store :opening_data, accessors: [:openings_desc, :openings, :openings_text, :openings_details], coder: JSON
  store :contact_data, accessors: [:telephone, :email, :website], coder: JSON

  validates_presence_of :item_type, :title, :main_place, :main_lat, :main_lng, :main_address, :main_town_insee_code,
                        :main_transports, :summary, :accessibility
  validates :accept_pictures, acceptance: true
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
    item.set_openings
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
    openings.blank? ? [] : openings.select {|k, v| !v.blank? && !v.to_s.include?('-')}.keys
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
    switched_codes = ["69007", "69064", "69097", "69119", "69253", "69189", "69193", "69235", "69080", "69118", "69236", "38544"]
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
    self.territory = TERRITORIES_BY_CODE[member_ref][Town.find_by_insee_code(main_town_insee_code).postal_code] if Town.find_by_insee_code(main_town_insee_code)
  end

  def set_openings(and_save = false)
    self.openings ||= {}
    self.openings_text = nil
    if external_id
      obj = EventsImporter.load_apidae_events([external_id], 'id', 'ouverture')
      if obj && obj.openings
        obj.openings.each do |o|
          if o[:dateDebut] == o[:dateFin]
            self.openings[o[:dateDebut]] = o[:identifiantTechnique]
          end
        end
        self.openings_text = obj.openings_description
        self.save if and_save
      end
    end
  end

  def self.set_openings_texts(items)
    remote_ids = items.map {|i| i.external_id}.select {|ext_id| !ext_id.blank?}.uniq
    objs = EventsImporter.load_apidae_events(remote_ids, ['id', 'ouverture'])
    items.each do |item|
      item.openings_text = nil
      unless item.external_id.blank?
        obj = objs.find {|o| o.id.to_i == item.external_id}
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
    openings[date].blank? ? "#{ref}-#{date.gsub('-', '')}" : openings[date]
  end

  def remote_save
    form_data = build_multipart_form(merge_data)
    response = save_to_apidae(user.territory, form_data, :api_url, :put)

    if external_id || (response['id'] && update_attributes!(external_id: response['id'], external_status: response['status']))
      update_apidae_criteria(user.territory, build_criteria((themes || []) + (criteria || []) + (validation_criteria || [])))
      bind_openings if rev == 1
      touch_remote_obj
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
      update_remote_ids(openings_map)
    else
      logger.error "Remote object not found : #{external_id}"
    end
  end

  def update_remote_ids(openings_map)
    kafka = Kafka.new([Rails.application.config.kafka_host], client_id: "jep_openings")
    openings_map.each_pair do |remote_id, local_id|
      logger.debug "Offer #{id} - Binding temp opening #{local_id} to period #{remote_id}"
      kafka.deliver_message('{"operation":"UPDATE_PERIOD","periodId":"' + local_id.to_s + '","updatedObject":{"externalId":' + remote_id.to_s + ', "externalRef":' + external_id.to_s + '}}',
                            topic: 'apidae_period')
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
                    nomDuLieu: value[:startingPoint]
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
            presentation: {
                descriptifCourt: {libelleFr: value[:shortDescription]},
                descriptifDetaille: {libelleFr: value[:longDescription]},
                typologiesPromoSitra: build_typologies(value[:themes])
            },
            prestations: {
                tourismesAdaptes: accessibility_values(value[:accessibility]),
                typesClientele: audience_values(value[:audience])
            },
            informationsFeteEtManifestation: {
                categories: build_categories(value[:categories]),
                themes: build_themes(value[:themes]),
                portee: {id: 2352, elementReferenceType: 'FeteEtManifestationPortee'},
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
                periodeEnClairGenerationMode: 'MANUEL',
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
    unless values.nil?
      APIDAE_CATEGORIES.each_pair do |cat, id|
        categories << {id: id, elementReferenceType: 'FeteEtManifestationCategorie'} if values.include?(cat.parameterize)
      end
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

  def build_typologies(values = [])
    typologies = []
    unless values.nil?
      APIDAE_TYPOLOGIES.each_pair do |typo, id|
        typologies << {id: id, elementReferenceType: 'TypologiePromoSitra'} if values.include?(typo.parameterize)
      end
    end
    typologies
  end

  def build_booking_data(data_hash = {})
    result = {}
    if data_hash[:booking]
      booking_data = {}
      booking_data[:organismes] = [
          structureReference: {
              id: user.legal_entity.external_id,
              type: 'STRUCTURE'
          },
          # Note : reservation directe par defaut (type obligatoire)
          type: {
              elementReferenceType: 'ReservationType',
              id: 475
          },
          moyensCommunication: [],
      ]
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

  def opening_times(openings_data)
    opening_periods = []
    openings_data.each_pair do |date, id|
      unless id.blank?
        op = apidate_opening(id)
        if op
          time_frames = op['timePeriods'].map {|tp| tp['timeFrames']}.flatten
          unless time_frames.blank?
            start_hour = time_frames.map {|tf| tf['startTime']}.min
            end_hour = time_frames.map {|tf| tf['endTime'] || ''}.max

            opening_period = {
                dateDebut: date,
                dateFin: date,
                horaireOuverture: (start_hour + ':00'),
                type: 'OUVERTURE_TOUS_LES_JOURS',
                tousLesAns: false
            }
            opening_period[:horaireFermeture] = (end_hour + ':00') unless end_hour.blank?
            opening_periods << opening_period
          end
        end
      end
    end
    opening_periods
  end

  def apidate_opening(id)
    apidate_url = Rails.application.config.apidate_api_url + '/apidae_period'
    logger.info "Retrieve openings : #{apidate_url}?id=#{CGI.escape('"' + id + '"')}"
    op = nil
    begin
      response = ''
      open(apidate_url + '?id=' + CGI.escape('"' + id + '"')) { |f|
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
