require 'csv'

class JepSite < ActiveRecord::Base
  store :site_data, accessors: [:ages], coder: JSON

  def self.export_full(csv_file)
    columns = ['place_uid', 'description', 'ages']

    CSV.open(Rails.root.join('data', csv_file), 'wb') do |csv|
      csv << columns
      JepSite.all.each do |s|
        csv << [s.place_uid, s.description, s.ages]
      end
    end
  end

  def self.import_full(csv_file)
    csv = CSV.new(File.new(csv_file), col_sep: ',', headers: :first_row)
    csv.each do |row|
      sites_fields = row.to_hash
      if sites_fields.length == row.headers.length
        # Todo : ages is converted to string in the process
        JepSite.create(sites_fields)
      else
        raise Exception.new('Invalid csv row : ' + sites_fields)
      end
    end
  end
end
