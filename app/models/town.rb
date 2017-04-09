require 'json'

class Town < ActiveRecord::Base
  has_many :legal_entities

  def self.matching(pattern)
    Town.where("trim(unaccent(replace(name, '-', ' '))) ILIKE trim(unaccent(replace(?, '-', ' '))) OR trim(postal_code) ILIKE trim(?)", "%#{pattern}%", "%#{pattern}%")
  end

  def self.import(json_file)
    result = true
    towns_json = File.read(json_file)
    towns_hashes = JSON.parse(towns_json, symbolize_names: true)
    towns_hashes.each do |town_data|
      Town.create!(name: town_data[:nom], postal_code: town_data[:codePostal], insee_code: town_data[:code],
                   country: 'fr', external_id: town_data[:id])
    end
    result
  end

  def label
    "#{name} (#{postal_code})"
  end
end
