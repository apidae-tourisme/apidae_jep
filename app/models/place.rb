require 'csv'

# Note : places are not linked to program_items yet, as this would require to validate/publish places in an independent db (WIP)
class Place < ActiveRecord::Base
  store :address_data, accessors: [:address1, :address2, :address3], coder: JSON
  store :access_data, accessors: [:access_details, :transports], coder: JSON

  belongs_to :town, foreign_key: :town_insee_code, primary_key: :insee_code

  validates_presence_of :name, :town_insee_code, :source

  before_create :generate_uid

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

  # Note : only places in France imported for now
  def self.import_from_apidae(apidae_places)
    imported_types = ['COMMERCE_ET_SERVICE', 'EQUIPEMENT', 'HOTELLERIE', 'HOTELLERIE_PLEIN_AIR', 'PATRIMOINE_CULTUREL',
                      'PATRIMOINE_NATUREL', 'RESTAURATION', 'STRUCTURE']
    towns_data = Town.all.collect {|t| {key: "#{t.name}-#{t.postal_code}", code: t.insee_code}}.group_by {|t| t[:key]}
    places = []
    import_csv(apidae_places) do |p|
      if p['type'] && imported_types.include?(p['type']) && !p['latitude'].blank? && (/^\d*$/ =~ p['codepostal']) != nil
        matched_town = towns_data["#{p['commune']}-#{p['codepostal']}"]
        if matched_town
          places << Place.new(name: p['nom'], address1: p['adresse1'], address2: p['adresse2'], address3: p['adresse3'],
                       town_insee_code: matched_town.first[:code], country: 'fr',
                       latitude: p['latitude'], longitude: p['longitude'], altitude: p['altitude'],
                       access_details: p['complement_adresse'], uid: SecureRandom.uuid, source: 'apidae')
        end
      end
    end
    # Bulk import skips AR callbacks, so uid is set manually
    Place.import places
  end

  def self.export_csv(csv_file)
    columns = ['uid', 'name', 'address', 'zipcode', 'town', 'inseecode', 'country', 'latitude', 'longitude', 'source']

    CSV.open(Rails.root.join('data', csv_file), 'wb') do |csv|
      csv << columns
      Place.all.includes(:town).each do |p|
        csv << p.to_csv
      end
    end
  end

  def to_csv
    [uid, name, [address1, address2, address3].join(' ').strip, town.postal_code, town.name, town_insee_code, country,
     latitude, longitude, source]
  end

  # descriptif,name,adresse1,adresse2,town,postal_code
  def self.import_from_isere(csv_file)
    import_csv(csv_file) do |p|
      if (/^\d*$/ =~ p['postal_code']) != nil
        matched_town = Town.where(name: p['town'], postal_code: p['postal_code']).first
        if matched_town
          matched_place = geocode_place(p['adresse1'], p['postal_code'], p['town'], 45.177879, 5.718545).first
          if matched_place
            lat = matched_place[:geometry][:coordinates][1]
            lng = matched_place[:geometry][:coordinates][0]
            place = Place.create(name: p['name'], address1: p['adresse1'], address2: p['adresse2'],
                         town_insee_code: matched_town.insee_code, country: 'fr',
                         latitude: lat, longitude: lng, source: 'isere')
            JepSite.create(description: p['descriptif'], place_uid: place.uid) unless p['descriptif'].blank?
          else
            puts "No match for #{[p['adresse1'], p['postal_code'], p['town']].join(' ').strip}"
            puts "Results : #{matched_place || 'none'}"
          end
        end
      end
    end
  end

  def self.import_from_lyon(csv_file)
    import_csv(csv_file) do |p|
      if (/^\d*$/ =~ p['postal_code']) != nil
        matched_town = Town.where(name: p['commune'], postal_code: p['postal_code']).first
        if matched_town
          place = Place.create(name: p['name'], address1: p['adresse1'], town_insee_code: matched_town.insee_code, country: 'fr',
                       latitude: p['latitude'], longitude: p['longitude'], access_details: p['access'], source: 'lyon')
          JepSite.create(description: p['descriptif'], ages: (p['epoque'].blank? ? [] : p['epoque'].strip.split('-')),
                         place_uid: place.uid) unless p['descriptif'].blank?
        else
          puts "Unmatched town : #{p['commune']} (#{p['postal_code']})"
        end
      end
    end
  end

  def self.geocode_place(address, postal_code, town, focus_lat, focus_lng)
    geocoding = ''
    query = [address, postal_code, town].join(' ').strip
    url = "https://search.mapzen.com/v1/search?api_key=mapzen-NY5Wumy&text=#{CGI.escape query}&focus.point.lat=#{focus_lat}&focus.point.lon=#{focus_lng}&layers=venue,address"
    open(url) {|f|
      f.each_line {|line| geocoding += line}
    }
    result = JSON.parse geocoding, symbolize_names: true
    result[:features] || []
  end

  private

  def generate_uid
    self.uid = SecureRandom.uuid
  end
end
