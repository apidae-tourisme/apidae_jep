# A toolkit to handle JSON bulk exports from the Apidae bulk api 'utilisateur/export-utilisateurs'

class ApidaeUsersImporter

  def self.json_to_csv(json_file, csv_file)
    users_json = File.read(json_file)
    users_data = JSON.parse(users_json, symbolize_names: true)

    CSV.open(csv_file, 'wb') do |csv|
      csv_columns = ['id', 'firstName', 'lastName', 'email', 'memberId', 'address', 'postalCode', 'town', 'entityName', 'entityId']
      csv << csv_columns
      users_data.each do |user|
        csv << [user[:id], user[:firstName], user[:lastName], user[:email], user[:membre],
                user[:adresse] ? user[:adresse][:adresse1] : '', user[:adresse] ? user[:adresse][:codePostal] : '',
                (user[:adresse] && user[:adresse][:commune]) ? user[:adresse][:commune][:nom] : '', user[:nomEntite] ? user[:nomEntite][:libelleFr] : '',
                user[:idEntite]]
      end
    end
  end
end
