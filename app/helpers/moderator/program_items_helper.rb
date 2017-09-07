module Moderator::ProgramItemsHelper
  def building_ages
    [
        ['Préhistoire'], ['Antiquité'], ['VIe'], ['VIIe'], ['VIIIe'],
        ['IXe'], ['Xe'], ['XIe'], ['XIIe'], ['XIIIe'], ['XIVe'], ['XVe'],
        ['XVIe'], ['XVIIe'], ['XVIIIe'], ['XIXe'], ['XXe'], ['XXIe']
    ]
  end

  def building_types
    [
        ["Château, hôtel urbain, palais, manoir"], ["Édifice religieux"], ["Édifice hospitalier"],
        ["Édifice maritime et fluvial"], ["Édifice militaire, enceinte urbaine"],
        ["Édifice industriel, scientifique et technique"], ["Édifice rural"], ["Édifice scolaire et éducatif"],
        ["Espace naturel, parc, jardin"], ["Édifice commémoratif"], ["Lieu de pouvoir, édifice judiciaire"],
        ["Lieu de spectacles, sports et loisirs"], ["Musée, salle d'exposition"], ["Site archéologique"],
        ["Maison, appartement, atelier de personnes célèbres"], ["Archives"]
    ]
  end

  def themes
    THEMES[current_moderator.member_ref].collect { |t| [t, t.parameterize] }
  end

  def criteria(item_type, selected)
    options = ''
    crits = CRITERIA[current_moderator.member_ref][item_type]
    if crits.is_a?(Hash)
      crits.each_pair do |k, v|
        options += generate_optgroup(k, v, selected)
      end
    else
      options = generate_options(crits, selected)
    end
    options.html_safe
  end

  def validation_criteria
    VALIDATION_CRITERIA[current_moderator.member_ref].collect { |t| [t, t.parameterize] }
  end

  def accessibility
    ACCESSIBILITY[current_moderator.member_ref]
  end

  def generate_optgroup(label, options, selected)
    '<optgroup label="' + label + '">' + generate_options(options, selected) + '</optgroup>'
  end

  def generate_options(options, selected)
    options.collect {
        |opt| '<option value="' + opt.parameterize + '"' + (selected && selected.include?(opt.parameterize) ? ' selected' : '') + '>' + opt + '</option>'
    }.join('')
  end

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

  def entity_label(entity)
    "#{entity.label} - Identifiant Apidae : #{entity.external_id}"
  end

  def exported_columns
    {
        item: ['reference', 'rev', 'status', 'external_id', 'item_type', 'title', 'description', 'short_desc', 'place_desc',
               'event_planners', 'building_ages', 'building_types', 'accessibility', 'criteria', 'themes',
               'validation_criteria', 'free', 'rates_desc', 'booking', 'booking_details', 'booking_telephone',
               'booking_email', 'booking_website', 'openings_desc', 'telephone', 'email', 'website', 'ordering',
               'main_place', 'main_lat', 'main_lng', 'main_address', 'town', 'main_transports', 'alt_place', 'updated_at',
               'validated_at'],
        program: ['program_title'],
        item_openings: ['opening_description'],
        attached_files: ['pictures'],
        user: ['user_name', 'user_email', 'user_telephone', 'user_entity']
    }
  end

  def exported_values(item)
    values = exported_columns[:item].collect do |c|
      val = item.send(c)
      format_value(c, val && val.is_a?(Array) ? val.select {|v| !v.blank?}.map {|v| ALL_REFS[v] || v}.join(' | ') : val)
    end
    values << item.program.title
    values << item.item_openings.collect {|o| format_opening(current_moderator.member_ref,o.description)}.join(' | ')
    values << item.attached_files.collect {|p| p.info}.join(' | ')
    values.each {|val| val.gsub!(/\r?\n|\r/, ' ') if val.is_a?(String)}
    values + [item.user.full_name, item.user.email, format_phone(item.user.telephone), item.user.legal_entity.name]
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
      formatted_openings.gsub!(/(vendredi|samedi|dimanche|lundi)/) {|m| m.slice(0, 3) + '.'}
      formatted_openings.gsub!(' septembre 2017', '')
      formatted_openings.gsub!('minutes', 'min')
      formatted_openings.gsub!(/(\d\sheures?)/) {|m| m.gsub(/(\sheures?)/, 'h')}
      formatted_openings.gsub!(/(heures?)/, 'h')
    elsif member_ref == ISERE
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
      dates[0..-2].each {|d| d.gsub!(' septembre 2016', '')}
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
    formatted_address
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
