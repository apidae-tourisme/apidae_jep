module User::ProgramItemsHelper
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
    THEMES[current_user.territory].collect { |t| [t, t.parameterize] }
  end

  def criteria(item_type, selected)
    options = ''
    crits = CRITERIA[current_user.territory][item_type]
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
    ACCESSIBILITY[current_user.territory]
  end

  def generate_optgroup(label, options, selected)
    '<optgroup label="' + label + '">' + generate_options(options, selected) + '</optgroup>'
  end

  def generate_options(options, selected)
    options.collect {
        |opt| '<option value="' + opt.parameterize + '"' + (selected && selected.include?(opt.parameterize) ? ' selected' : '') + '>' + opt + '</option>'
    }.join('')
  end
end
