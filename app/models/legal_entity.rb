class LegalEntity < ActiveRecord::Base
  store :address, accessors: [:adresse1, :adresse2, :adresse3], coder: JSON
  has_many :users
  belongs_to :town, foreign_key: :town_insee_code, primary_key: :insee_code

  before_create :normalize_website_url

  include WritableConcern

  validates_presence_of :name

  def self.matching(pattern)
    LegalEntity.where("trim(unaccent(replace(name, '-', ' '))) ILIKE trim(unaccent(replace(?, '-', ' ')))", "%#{pattern}%")
  end

  def active_items(year)
    users.collect {|u| u.active_items(year)}.flatten.uniq
  end

  def street_address
    adresse1
  end

  def street_address=(val)
    self.adresse1 = val
  end

  def full_address
    (address.values + [town.postal_code, town.name]).join("\n")
  end

  def label
    "#{name} - #{town.label}"
  end

  def normalize_website_url
    unless website.blank? || website.start_with?('http')
      self.website = 'http://' + website
    end
  end

  # Note - grouped JSON exports expected
  def self.import(json_dir)
    result = false
    if Dir.exist?(json_dir)
      Dir.foreach(json_dir) do |f|
        if f.end_with?('.json')
          json_file = File.join(json_dir, f)
          entities_json = File.read(json_file)
          entities_hashes = JSON.parse(entities_json, symbolize_names: true)
          entities_hashes.each do |entity_data|
            if entity_data[:type] == 'STRUCTURE'
              entity_town = Town.find_by_external_id(entity_data[:localisation][:adresse][:commune][:id])
              if entity_town
                LegalEntity.create!(
                    name: entity_data[:nom][:libelleFr],
                    adresse1: entity_data[:localisation][:adresse][:adresse1],
                    adresse2: entity_data[:localisation][:adresse][:adresse2],
                    adresse3: entity_data[:localisation][:adresse][:adresse3],
                    town: entity_town,
                    email: contact_info(entity_data[:informations][:moyensCommunication], 204),
                    phone: contact_info(entity_data[:informations][:moyensCommunication], 201),
                    website: contact_info(entity_data[:informations][:moyensCommunication], 205),
                    external_id: entity_data[:id])
              end
            end
          end
        end
        result = true
      end
      result
    end
  end

  def self.batch_update(json_dir)
    result = false
    if Dir.exist?(json_dir)
      Dir.foreach(json_dir) do |f|
        if f.end_with?('.json')
          json_file = File.join(json_dir, f)
          entities_json = File.read(json_file)
          entities_hashes = JSON.parse(entities_json, symbolize_names: true)
          entities_hashes.each do |entity_data|
            if entity_data[:type] == 'STRUCTURE'
              yield(entity_data)
            end
          end
        end
        result = true
      end
      result
    end
  end

  def remote_save(member_ref)
    response = save_to_apidae(member_ref, build_multipart_form, :api_url, :put)
    if response['id']
      self.external_id = response['id']
      save!
    end
  end

  def build_multipart_form
    form_data = {
        'mode' => WritableConcern::CREATE,
        'type' => 'STRUCTURE',
        'fields' => '["root"]',
        'skipValidation' => 'true',
        'root' => '{"type":"STRUCTURE"}',
        'root.fieldList' => '[]'
    }

    entity_data = build_form_data
    merged_data = safe_merge(extract_as_hash(form_data['root']), entity_data)
    form_data['root'] = JSON.generate(merged_data)
    impacted_fields = data_fields(entity_data, Array.new)
    form_data['root.fieldList'] = merge_fields(form_data['root.fieldList'], impacted_fields)

    form_data
  end

  def to_json_hash
    JSON.generate(
        {
            id: id,
            name: name,
            email: email,
            phone: phone,
            website: website,
            address: adresse1,
            postal_code: town.postal_code,
            town: town.name,
            external_id: external_id
        }
    )
  end

  private

  def self.contact_info(contact_fields, field_id)
    contact_field = ''
    if contact_fields
      contact_node = contact_fields.select { |f| f[:type][:id] == field_id }.first
      contact_field = contact_node[:coordonnees][:fr] if contact_node && contact_node[:coordonnees]
    end
    contact_field
  end

  def build_form_data
    {
        nom: {libelleFr: name},
        localisation: {
            adresse: {
                adresse1: adresse1,
                codePostal: town.postal_code,
                etat: 'France',
                commune: {id: town.external_id}
            }
        },
        informations: {
            moyensCommunication: contact_info({phone: phone, email: email, website: website})
        }
    }
  end
end