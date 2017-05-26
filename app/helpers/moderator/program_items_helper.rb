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
end
