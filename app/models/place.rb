require 'csv'

# Note : places are not linked to program_items yet, as this would require to validate/publish places in an independent db (WIP)
class Place < ActiveRecord::Base
  store :address_data, accessors: [:address1, :address2, :address3], coder: JSON
  store :access_data, accessors: [:access_details, :transports], coder: JSON

  belongs_to :town, foreign_key: :town_insee_code, primary_key: :insee_code

  validates_presence_of :name, :town, :source

  def self.import_csv(csv_file)
    csv = CSV.new(File.new(csv_file), col_sep: ',', headers: :first_row)
    csv.each do |row|
      places_fields = row.to_hash
      if places_fields.length == row.headers.length
        yield(places_fields)
      else
        raise Exception.new('Invalid csv row : ' + places_fields)
      end
    end
  end

  def self.import_from_apidae(apidae_places)
    imported_types = ['COMMERCE_ET_SERVICE', 'EQUIPEMENT', 'HOTELLERIE', 'HOTELLERIE_PLEIN_AIR', 'PATRIMOINE_CULTUREL',
                      'PATRIMOINE_NATUREL', 'RESTAURATION', 'STRUCTURE']
    import_csv(apidae_places) do |p|
      if p['type'] && imported_types.include?(p['type'])
        matched_towns = Town.where(name: p['commune'], postal_code: p['codepostal'])
        if matched_towns.count == 1
          Place.create(name: p['nom'], address1: p['adresse1'], address2: p['adresse2'], address3: p['adresse3'],
                       town: matched_towns.first, latitude: p['latitude'], longitude: p['longitude'], altitude: p['altitude'],
                       access_details: p['complement_adresse'], source: 'apidae')
        else
          puts "Unmatched town : #{p['commune']} (#{p['codepostal']})"
        end
      end
    end
  end

  def self.export_as_json

  end
end
