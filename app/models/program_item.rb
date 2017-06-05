#encoding: UTF-8

class ProgramItem < ActiveRecord::Base
  include LoggableConcern
  include WritableConcern

  belongs_to :program
  belongs_to :user
  has_many :item_openings
  has_many :attached_files

  accepts_nested_attributes_for :item_openings, allow_destroy: true
  accepts_nested_attributes_for :attached_files, allow_destroy: true, reject_if: proc {|attrs| attrs['picture'].blank?}

  STATUS_DRAFT = 'draft'
  STATUS_PENDING = 'pending'
  STATUS_VALIDATING = 'validating'
  STATUS_VALIDATED = 'validated'
  STATUS_REJECTED = 'rejected'
  STATUS_APIDAE_ERROR = 'apidae_error'

  DIRECTION_UP = 'up'
  DIRECTION_DOWN = 'down'

  store :desc_data, accessors: [:place_desc, :place_desc_ref, :event_planners, :building_ages, :building_types, :accessibility,
                                :audience, :criteria, :themes, :accept_pictures], coder: JSON
  store :location_data, accessors: [:main_place, :main_lat, :main_lng, :main_address, :main_town_insee_code,
                                    :main_transports, :alt_place, :alt_lat, :alt_lng, :alt_address,
                                    :alt_town_insee_code, :alt_postal_code, :alt_transports], coder: JSON
  store :rates_data, accessors: [:free, :rates_desc, :booking, :booking_details, :booking_telephone, :booking_email, :booking_website], coder: JSON
  store :opening_data, accessors: [:openings_desc], coder: JSON
  store :contact_data, accessors: [:telephone, :email, :website], coder: JSON

  validates_presence_of :item_type, :title, :main_place, :main_address, :main_town_insee_code, :main_transports,
                        :description, :accessibility, :item_openings
  validates :accept_pictures, acceptance: true

  def self.change_order(item, direction)
    ordered_items = item.program.ordered_items
    item_index = ordered_items.index(item)
    if direction == DIRECTION_UP && item != ordered_items.first
      ordered_items.each do |itm|
        itm.update(ordering:  itm.ordering + 1) if (ordered_items.index(item) >= item_index - 1 && itm != item)
      end
      item.update(ordering: item.ordering - 1)
    elsif direction == DIRECTION_DOWN && item != ordered_items.last
      ordered_items.each do |itm|
        itm.update(ordering:  itm.ordering - 1) if (ordered_items.index(item) >= item_index - 1 && itm != item)
      end
      item.update(ordering: item.ordering + 1)
    end
  end

  def last_revision
    ProgramItem.where(reference: reference).order(:rev).last
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

  def opening_text(opening)
    openings.include?(opening) ? opening.as_text : ''
  end

  def self.active_versions
    active_ids = select("MAX(id) AS id").group(:reference)
    where(id: active_ids)
  end

  def self.visible
    where(status: [STATUS_PENDING, STATUS_VALIDATED, STATUS_REJECTED])
  end

  def self.in_status(territory, *statuses)
    active_versions.where("program_items.status IN (?) AND users.territory = ?", statuses, territory)
        .joins("JOIN users ON users.id = program_items.user_id")
  end

  def self.validated(program_id = nil)
    items = where(status: STATUS_VALIDATED)
    program_id ? items.where(program_id: program_id) : items
  end

  def self.draft(program_id = nil)
    items = where(status: STATUS_DRAFT)
    program_id ? items.where(program_id: program_id) : items
  end

  def self.rejected(program_id = nil)
    items = where(status: STATUS_REJECTED)
    program_id ? items.where(program_id: program_id) : items
  end

  def remote_save
    form_data = build_multipart_form(merge_data)
    response = save_to_apidae(user.territory, form_data, :api_url, :put)

    if external_id || (response['id'] && update_attributes!(external_id: response['id'], external_status: response['status']))
      update_apidae_criteria(user.territory, build_criteria(themes + criteria))
    end
  end

  def merge_data
    merged = {}

    unless location_data.nil? || location_data.empty?
      place_town = Town.find_by_insee_code(main_town_insee_code)
      merged[:place] = {
          name: main_place, startingPoint: alt_place, address: main_address,
          postal_code: place_town.postal_code, latitude: main_lat, longitude: main_lng,
          extraInfo: alt_place, external_id: place_town.external_id
      }
    end

    unless desc_data.nil? || desc_data.empty?
      merged[:description] = {
          name: title, shortDescription: description[0..254],
          longDescription: description, planners: event_planners,
          accessibility: accessibility,
          audience: themes,
          categories: criteria,
          themes: themes + criteria
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
          free: free, description: rates_desc
      }
      merged[:booking] = {
          booking: booking, bookingDetails: booking_details,
          bookingPhone: booking_telephone, bookingEmail: booking_email, bookingWebsite: booking_website
      }
    end

    merged[:openings] = item_openings.to_a

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
        form_data["multimedia.#{attachment_key}"] = Faraday::UploadIO.new(attachment.picture.path, attachment.picture_content_type)
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
                    commune: {id: value[:external_id]}
                },
                geolocalisation: {
                    valide: true,
                    complement: {libelleFr: value[:extraInfo]},
                    geoJson: {
                        type: 'Point',
                        coordinates: [value[:longitude], value[:latitude]]
                    }
                },
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
                themes: build_themes(value),
                portee: {id: 2352, elementReferenceType: 'FeteEtManifestationPortee'},
                evenementGenerique: {id: 2388, elementReferenceType: 'FeteEtManifestationGenerique'}
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
                periodeEnClair: {libelleFr: format_openings(value)},
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
    APIDAE_CATEGORIES.each_pair do |cat, id|
      categories << {id: id, elementReferenceType: 'FeteEtManifestationCategorie'} if values.include?(cat.parameterize)
    end
    categories
  end

  def build_themes(values = [])
    themes = []
    APIDAE_THEMES.each_pair do |th, id|
      themes << {id: id, elementReferenceType: 'FeteEtManifestationTheme'} if values.include?(th.parameterize)
    end
    themes
  end

  def build_typologies(values = [])
    typologies = []
    APIDAE_TYPOLOGIES.each_pair do |typo, id|
      typologies << {id: id, elementReferenceType: 'TypologiePromoSitra'} if values.include?(typo.parameterize)
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
      booking_data[:complement] = {libelleFr: (data_hash[:booking] ? 'Réservation recommandée' : 'Réservation obligatoire')}
      booking_data[:complement][:libelleFr] += "\n#{data_hash[:bookingDetails]}" unless data_hash[:bookingDetails].blank?
      result[:reservation] = booking_data
    end
    result
  end

  def build_criteria(selected = [])
    input_refs = selected + [item_type]
    added = []
    APIDAE_CRITERIA.each_pair do |crit, id|
      added << id if input_refs.include?(crit.parameterize)
    end
    removed = APIDAE_CRITERIA.values - added
    {added: added, removed: removed}
  end

  def opening_times(openings)
    opening_times = []
    openings_by_day = openings.group_by {|o| o.starts_at.to_date}
    openings_by_day.each_pair do |date, ops|
      ref_opening = ops.first
      opening_time = {
          dateDebut: date.strftime('%F'),
          dateFin: date.strftime('%F'),
          horaireOuverture: ref_opening.starts_at.strftime('%T'),
          type: 'OUVERTURE_TOUS_LES_JOURS',
          tousLesAns: false
      }
      opening_time[:horaireFermeture] = ref_opening.ends_at.strftime('%T') if ref_opening.ends_at
      opening_times << opening_time
    end
    opening_times
  end

end
