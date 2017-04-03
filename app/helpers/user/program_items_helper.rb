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
end
