#encoding: UTF-8

module WritableConcern
  extend ActiveSupport::Concern

  CREATE = 'CREATION'
  UPDATE = 'MODIFICATION'
  DELETE = 'DEMANDE_SUPPRESSION'

  def safe_merge(first_hash, other_hash)
    first_hash.merge(other_hash) do |key, old_value, new_value|
      if old_value.is_a?(Hash) && new_value.is_a?(Hash)
        safe_merge(old_value, new_value)
      end
    end
  end

  def compute_member_ref(postal_code)
    if postal_code.start_with?('69')
      'grandlyon'
    elsif postal_code.start_with?('38') || postal_code.start_with?('73') || postal_code.start_with?('26')
      'isere'
    else
      raise Exception.new("Unsupported postal code : #{postal_code} - Cannot find corresponding member")
    end
  end

  def data_fields(data_hash, parsed_fields, parent_fields = [])
    excluded_fields = [:libelleFr]
    excluded_nodes = [:commune, :geoJson, :structureGestion, :portee, :evenementGenerique]
    data_hash.each_pair do |k, v|
      if v.is_a?(Hash) && (v.keys & excluded_fields).empty? && !excluded_nodes.include?(k)
        data_fields(v, parsed_fields, parent_fields + [k])
      else
        parsed_fields << (parent_fields + [k]).join('.')
      end
    end
    parsed_fields
  end

  def merge_fields(current_fields, new_fields)
    serialized_fields = '"' + new_fields.join('","') + '"'
    serialized_fields.prepend(',') if current_fields.include?('"')
    current_fields.insert(current_fields.index(']'), serialized_fields)
  end

  def extract_as_hash(json_data)
    JSON.parse(json_data, symbolize_names: true)
  end

  def contact_info(data_hash)
    contacts = []
    unless data_hash[:phone].blank?
      contacts << {type: {id: 201, elementReferenceType: 'MoyenCommunicationType'}, coordonnees: {fr: data_hash[:phone]}}
    end
    unless data_hash[:email].blank?
      contacts << {type: {id: 204, elementReferenceType: 'MoyenCommunicationType'}, coordonnees: {fr: data_hash[:email]}}
    end
    unless data_hash[:website].blank?
      contacts << {type: {id: 205, elementReferenceType: 'MoyenCommunicationType'}, coordonnees: {fr: data_hash[:website]}}
    end
    contacts
  end

  def save_to_apidae(member, form_data, url_key, verb)
    oauth_config = Rails.application.config.oauth_config
    client = OAuth2::Client.new(oauth_config[member.to_sym][:client_id], oauth_config[member.to_sym][:client_secret],
                                :site => oauth_config[:auth_site], :token_url => oauth_config[:token_path],
                                :token_method => :get)
    current_token = AuthToken.active_token(member) || renew_token(client, member)

    logger.debug("Multipart url : #{oauth_config[url_key]}")
    logger.debug("Multipart params : #{member} - #{oauth_config[member.to_sym][:client_id]} - #{oauth_config[member.to_sym][:client_secret]}")
    logger.debug("Multipart form data : #{form_data}")
    multipart_client = OAuth2::Client.new(oauth_config[member.to_sym][:client_id], oauth_config[member.to_sym][:client_secret],
                                          :site => oauth_config[:auth_site]) do |conn|
      conn.request :multipart
      conn.request :url_encoded
      conn.adapter Faraday.default_adapter
    end
    multipart_token = OAuth2::AccessToken.new(multipart_client, current_token.token)
    response = nil
    unless Rails.env.development? || ENV['APIDAE_DRY_RUN']
      response = multipart_token.request(verb, oauth_config[url_key]) do |req|
        req.headers['Content-Type'] = 'multipart/form-data'
        req.body = form_data
      end
    end
    result = {}
    if response && response.respond_to?(:parsed)
      result = response.parsed
    end
    logger.debug "remote save result : #{result}"
    result
  end

  def renew_token(oauth_client, member)
    new_token = oauth_client.client_credentials.get_token
    auth_token = AuthToken.new({:token => new_token.token, member_ref: member})
    auth_token.expires_in = new_token.expires_in
    auth_token.save!
    auth_token
  end

end