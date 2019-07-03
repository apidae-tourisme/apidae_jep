module ItemConcern

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

  def current_territory
    current_user ? current_user.territory : current_moderator.member_ref
  end

  def themes
    THEMES[current_territory].collect { |t| [t, t.parameterize] }
  end

  def criteria(item_type, selected)
    options = ''
    crits = CRITERIA[current_territory][item_type]
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
    ACCESSIBILITY[current_territory]
  end

  def generate_optgroup(label, options, selected)
    '<optgroup label="' + label + '">' + generate_options(options, selected) + '</optgroup>'
  end

  def generate_options(options, selected)
    options.collect {
        |opt| '<option value="' + opt.parameterize + '"' + (selected && selected.include?(opt.parameterize) ? ' selected' : '') + '>' + opt + '</option>'
    }.join('')
  end

  def ellipsis(text)
    text.length > 255 ? (text[0, 255] + '...') : text
  end

  def entity_label(entity)
    "#{entity.label} - Identifiant Apidae : #{entity.external_id}"
  end
end