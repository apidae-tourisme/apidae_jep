module Moderator::ProgramItemsHelper
  include ItemConcern

  def render_previous(attr, rows = 1)
    if @prev_item
      @prev_item.send(attr) != @item.send(attr) ? "<textarea class='mt-sm previous_val form-control' rows='#{rows}' readonly='readonly'>#{stringify(@prev_item.send(attr), attr)}</textarea>".html_safe : ''
    elsif attr == :place_desc && @item.place_desc != @item.place_desc_ref
      "<textarea class='mt-sm previous_val form-control' rows='#{rows}' readonly='readonly'>#{@item.place_desc_ref}</textarea>".html_safe
    end
  end

  def render_previous_assoc(prev_objects, new_objects, attr, rows = 1)
    prev_values = prev_objects.collect {|obj| obj.send(attr)}
    new_values = new_objects.collect {|obj| obj.send(attr)}
    if prev_values.to_set != new_values.to_set
      if attr == :picture_url
        ("<div class='row'><p class='col-sm-12 text-warning'>Photos précédentes</p>" + prev_values.map {|v| "<div class='col-sm-2'>#{image_tag(v)}</div>"}.join('') + "</div>").html_safe
      else
        prev_values.map {|v| "<textarea class='mt-xl previous_val form-control' rows='#{rows}' readonly='readonly'>#{stringify(v, attr)}</textarea>"}.join('<br/>').html_safe
      end
    else
      ''
    end
  end

  def stringify(val, attr)
    if attr == :free
      val == 'true' ? 'Accès gratuit' : 'Accès payant'
    else
      val.is_a?(Array) ? val.select {|v| !v.blank?}.map {|v| I18n.t("ref.#{v}") }.join(' | ') : val
    end
  end

  def exported_columns
    {
        item_0: ['reference', 'rev', 'status', 'external_id', 'main_lat', 'main_lng', 'town', 'themes', 'main_place',
               'accessibility', 'validation_criteria', 'building_ages', 'building_types', 'place_desc', 'ordering',
               'title', 'item_type', 'criteria', 'description', 'summary', 'accept_safety', 'covid_desc'],
        item_openings: ['opening_description'],
        item_1: ['openings_desc', 'free', 'rates_desc', 'booking', 'booking_details', 'booking_telephone',
                   'booking_email', 'booking_website', 'main_address', 'alt_place', 'main_transports', 'telephone',
                   'email', 'website'],
        user_0: ['user_entity'],
        item_2: ['event_planners'],
        user_1: ['user_name', 'user_email', 'user_telephone'],
        attached_files: ['pictures'],
        item_3: ['updated_at', 'validated_at']
    }
  end

  def cols_width
    [nil, nil, nil, nil, nil, nil, nil, nil, nil, 100, nil, nil, nil, 100, nil, 100, nil, nil, 100, 100, nil, 100, 100,
     100, nil, 100, nil, 100, nil, nil, nil, nil, nil, 100, nil, nil, nil, nil, 100, nil, nil, nil, 100, nil, nil]
  end

  def exported_values(item)
    values = item_values(item, exported_columns[:item_0])
    values << format_opening(current_moderator.member_ref, item.openings_text)
    values += item_values(item, exported_columns[:item_1])
    values << item.user.legal_entity.name
    values += item_values(item, exported_columns[:item_2])
    values += [item.user.full_name, item.user.email, format_phone(item.user.telephone)]
    values << item.attached_files.collect {|p| p.info}.join(' | ')
    values += item_values(item, exported_columns[:item_3])
    values.each {|val| val.gsub!(/\r?\n|\r/, ' ') if val.is_a?(String)}
    values
  end

  def item_values(item, columns)
    columns.collect do |c|
      val = item.send(c)
      format_value(c, val && val.is_a?(Array) ? val.select {|v| !v.blank?}.map {|v| ALL_REFS[v] || v}.join(' | ') : val)
    end
  end

  def format_value(key, value)
    val = (value.blank? || !value.is_a?(String)) ? value : value.strip
    case key
      when 'main_transports'
        format_transports(val)
      when 'main_address'
        format_address(val)
      when 'booking_telephone', 'telephone'
        format_phone(val)
      when 'booking_website', 'website'
        format_website(val)
      when 'town'
        format_town(val)
      when 'updated_at', 'validated_at'
        format_date(val)
      when 'building_ages'
        val.gsub('e', 'ᵉ')
      when 'user_entity', 'event_planners'
        val.capitalize
      when 'rates_desc', 'booking_details'
        val.gsub(/(\.)$/, '')
      else
        val
    end
  end

  def format_date(val)
    I18n.l(val) unless val.blank?
  end

  def format_opening(member_ref, openings_desc)
    formatted_openings = openings_desc.blank? ? '' : openings_desc.strip
    formatted_openings.gsub!(':00', 'h')
    if member_ref == GRAND_LYON
      formatted_openings = formatted_openings.downcase
      formatted_openings.gsub!(' tous les jours ', '')
      formatted_openings.gsub!(/(vendredi|samedi|dimanche|lundi)/) {|m| m.slice(0, 3) + '.'}
      formatted_openings.gsub!(/(19|20|21|22) septembre 2025/, '')
      formatted_openings.gsub!('minutes', 'min.')
      formatted_openings.gsub!(/(\d\sheures?)/) {|m| m.gsub(/(\sheures?)/, 'h')}
      formatted_openings.gsub!(/(heures?)/, 'h')
      formatted_openings.gsub!(/(ouverture)/, '')
      formatted_openings.gsub!(/(\s\s\s?)/, ' ')
      formatted_openings.gsub!(/(\.)$/, '')
    elsif member_ref == ISERE
      formatted_openings.gsub!(' tous les jours ', ' ')
      # open_days = formatted_openings.split("\n")
      # if open_days.length > 1
      #   parsed_openings = {}
      #   open_days.each do |d|
      #     opening_fields = d.split(' : ')
      #     if opening_fields.length == 2
      #       parsed_openings[opening_fields[1]] ||= []
      #       parsed_openings[opening_fields[1]] << opening_fields[0]
      #     else
      #       parsed_openings[d] = []
      #     end
      #   end
      #   formatted_openings = parsed_openings.keys.collect {|o| parsed_openings[o].empty? ? o : format_same_hours(o, parsed_openings[o])}.join("\n")
      # end
    end
    formatted_openings
  end

  def format_same_hours(hour, dates)
    if dates.length == 1
      "#{dates[0]} : #{hour}"
    else
      dates[0..-1].each {|d| d.downcase!}
      dates[0..-2].each {|d| d.gsub!(' septembre 2025', '')}
      "#{dates[0..-2].join(', ')} et #{dates.last} #{hour}".capitalize
    end
  end

  def format_transports(transports_desc)
    transports_desc.gsub(/Tramway/i) {|m| m.slice(0, 4)} unless transports_desc.nil?
  end

  def format_address(address)
    formatted_address = address.gsub(/(\s?\,\s?)/, ' ')
    mappings = {'boulevard' => 'bd', 'rue' => 'rue', 'avenue' => 'av', 'chemin' => 'che', 'impasse' => 'imp',
                'cours' => 'crs', 'place' => 'pl', 'batiment' => 'bât', 'montee' => 'mtée',
                'route' => 'rte', 'rez-de-chaussee' => 'rdc'}
    mappings_hash = Hash.new {|h, k| h[k] = mappings[k.downcase.parameterize]}
    formatted_address.gsub!(/(boulevard|avenue|chemin|impasse|cours|place|b(â|a)timent|mont(é|e)e|route|rue|rez.de.chauss(é|e)e)/i, mappings_hash)
    formatted_address.capitalize
  end

  def format_phone(phone_number)
    formatted_phone = phone_number.blank? ? '' : phone_number.strip.gsub(/(\s|\.)/, '')
    if formatted_phone.start_with?('0') && formatted_phone.length == 10
      formatted_phone.gsub!(/\d{2}/) {|m| m + ' '}
    end
    formatted_phone
  end

  def format_website(website_url)
    website_url.strip.gsub(/(https?:\/\/)/, '') unless website_url.blank?
  end

  def format_town(town)
    formatted_town = town.blank? ? '' : town.strip
    formatted_town.gsub!(/(Lyon\s\d\p{Alpha}+)/) {|m| m.slice(0, 6)}
    formatted_town
  end
end
