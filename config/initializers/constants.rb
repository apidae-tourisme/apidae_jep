GRAND_LYON = "grand_lyon"
ISERE = "isere"
SAUMUR = "saumur"
DLVA = "dlva"

EDITION = 2021

ITEM_VISITE = "visite"
ITEM_PARCOURS = "parcours"
ITEM_ANIMATION = "animation"
ITEM_EXPOSITION = "exposition"

ITEM_TYPES = [ITEM_VISITE, ITEM_PARCOURS, ITEM_ANIMATION, ITEM_EXPOSITION]

THEMES = {
    GRAND_LYON => ["Thématique métropole 2021 - Jeunesse", "Thématique nationale 2021 - \"Patrimoine pour tous\"", "Nouveauté",
                   "En famille", "Egalité"],
    ISERE => ["Thématique nationale 2021 - \"Patrimoine pour tous\"", "Famille", "Réservé aux enfants", "Antiquité",
              "Archéologie", "Architecture", "Art contemporain", "Artisanat", "Littérature", "Historique"],
    SAUMUR => ["Thématique nationale 2021 - \"Patrimoine pour tous\"", "JEP | Première ouverture", "Famille", "Réservé aux enfants", "Antiquité",
                     "Archéologie", "Architecture", "Art contemporain", "Artisanat", "Littérature", "Historique", "Œnologie"],
    DLVA => ["Thématique nationale 2021 - \"Patrimoine pour tous\"", "Famille", "Réservé aux enfants", "Antiquité",
              "Archéologie", "Architecture", "Art contemporain", "Artisanat", "Littérature", "Historique"]
}
THEMES_REFS = Hash[THEMES.values.flatten.collect {|th| [th.parameterize, th] }]

VALIDATION_CRITERIA = {
    GRAND_LYON => ['Coup de coeur', 'Visites guidées de l\'Office du Tourisme', 'Balades urbaines du Musée Gadagne',
                   'Sous-thématique 1', 'Sous-thématique 2', 'Sous-thématique 3', 'Sous-thématique 4', 'Sous-thématique 5'],
    ISERE => [],
    SAUMUR => ['Demeure privée', 'Site troglodyte'],
    DLVA => []
}
VALIDATION_CRITERIA_REFS = Hash[VALIDATION_CRITERIA.values.flatten.collect {|th| [th.parameterize, th] }]

CRITERIA = {
    GRAND_LYON => {
      ITEM_VISITE => ["Visite guidée", "Visite libre"],
      ITEM_PARCOURS => ["Parcours", "Croisière", "Visite guidée", "Visite libre"],
      ITEM_ANIMATION => {
          "Intervention artistique" => ["Théâtre", "Concert", "Danse", "Lecture", "Conte"],
          "Conférence / Débat / Projection" => ["Conférence / Débat", "Projection"],
          "Savoirs-faire" => ["Démonstration", "Dégustation"],
          "Animation participative" => ["Jeux", "Atelier"]
      },
      ITEM_EXPOSITION => ["Visite guidée", "Visite libre"]
    },
    ISERE => {
        ITEM_VISITE => ["Visite guidée", "Visite libre"],
        ITEM_PARCOURS => ["Visite guidée", "Visite libre"],
        ITEM_ANIMATION => ["Concert", "Conférence / Débat", "Danse", "Dégustation", "Démonstration", "Goûter",
                           "Atelier", "Jeu de piste / Chasse au trésor", "Marché", "Balade contée", "Cinéma", "Conte",
                           "Dessin", "Loisirs créatifs", "Peinture", "Photographie"],
        ITEM_EXPOSITION => ["Visite guidée", "Visite libre"]
    },
    SAUMUR => {
        ITEM_VISITE => ["Visite guidée", "Visite libre"],
        ITEM_PARCOURS => ["Visite guidée", "Visite libre"],
        ITEM_ANIMATION => ["Concert", "Conférence / Débat", "Danse", "Dégustation", "Démonstration", "Goûter",
                           "Atelier", "Jeu de piste / Chasse au trésor", "Marché", "Balade contée", "Cinéma", "Conte",
                           "Théâtre", "Dessin", "Loisirs créatifs", "Peinture", "Photographie"],
        ITEM_EXPOSITION => ["Visite guidée", "Visite libre"]
    },
    DLVA => {
      ITEM_VISITE => ["Visite guidée", "Visite libre"],
      ITEM_PARCOURS => ["Visite guidée", "Visite libre"],
      ITEM_ANIMATION => ["Concert", "Conférence / Débat", "Danse", "Dégustation", "Démonstration", "Goûter",
                         "Atelier", "Jeu de piste / Chasse au trésor", "Marché", "Balade contée", "Cinéma", "Conte",
                         "Dessin", "Loisirs créatifs", "Peinture", "Photographie"],
      ITEM_EXPOSITION => ["Visite guidée", "Visite libre"]
    }
}
CRITERIA_REFS = Hash[CRITERIA.values.collect {|v| v.values.collect {|val| val.is_a?(Hash) ? val.values.flatten : val}.flatten}.flatten.uniq.collect {|crit| [crit.parameterize, crit]}]

ACCESSIBILITY = {
    GRAND_LYON => {
        'fully_accessible' => "Personnes à mobilité réduite (accès total)",
        'partly_accessible' => "Personnes à mobilité réduite (accès partiel)",
        'not_accessible' => "Non accessible en fauteuil roulant",
        'deaf_people' => "Personnes malentendantes ou sourdes",
        'blind_people' => "Personnes malvoyantes ou non voyantes"
    },
    ISERE => {
        'fully_accessible' => "Personnes à mobilité réduite (accès total)",
        'partly_accessible' => "Personnes à mobilité réduite (accès partiel)",
        'not_accessible' => "Non accessible en fauteuil roulant",
        'deaf_people' => "Personnes malentendantes ou sourdes",
        'blind_people' => "Personnes malvoyantes ou non voyantes"
    },
    SAUMUR => {
        'fully_accessible' => "Personnes à mobilité réduite (accès total)",
        'partly_accessible' => "Personnes à mobilité réduite (accès partiel)",
        'not_accessible' => "Non accessible en fauteuil roulant",
        'deaf_people' => "Personnes malentendantes ou sourdes",
        'blind_people' => "Personnes malvoyantes ou non voyantes"
    },
    DLVA => {
      'fully_accessible' => "Personnes à mobilité réduite (accès total)",
      'partly_accessible' => "Personnes à mobilité réduite (accès partiel)",
      'not_accessible' => "Non accessible en fauteuil roulant",
      'deaf_people' => "Personnes malentendantes ou sourdes",
      'blind_people' => "Personnes malvoyantes ou non voyantes"
    }
}
ACCESSIBILITY_REFS = ACCESSIBILITY.values.inject(:merge)

ALL_REFS = THEMES_REFS.merge(VALIDATION_CRITERIA_REFS).merge(CRITERIA_REFS).merge(ACCESSIBILITY_REFS)

APIDAE_CRITERIA = {
    'Nouveauté' => 7997,
    "Visite libre" => 10173,
    'Egalité' => 10161,
    'animation' => 10171,
    'parcours' => 10172,
    'Sous-thématique 1' => 10164,
    'Sous-thématique 2' => 10165,
    'Sous-thématique 3' => 10166,
    'Sous-thématique 4' => 10167,
    'Sous-thématique 5' => 10168,
    'Coup de coeur' => 7998,
    'Visites guidées de l\'Office du Tourisme' => 8778,
    'Balades urbaines du Musée Gadagne' => 8292,
    'Demeure privée' => 17728,
    'JEP | Première ouverture' => 17818,
    'Thématique métropole 2021 - Jeunesse' => 19807
}

APIDAE_TYPOLOGIES = {
    "Thématique nationale 2021 - \"Patrimoine pour tous\"" => 6445
}

APIDAE_ENVIRONMENTS = {
    "Site troglodyte" => 5894
}

APIDAE_THEMES = {
    'Conte' => 2276,
    'Lecture' => 2308,
    "Sur l'eau" => 2173,
    'En vélo' => 2338,
    'Balade contée' => 2158,
    'Cinéma' => 2133,
    'Dessin' => 2304,
    'Loisirs créatifs' => 2144,
    'Peinture' => 2232,
    'Photographie' => 2235,
    'Antiquité' => 2274,
    'Archéologie' => 3831,
    'Architecture' => 2126,
    'Art contemporain' => 2159,
    'Artisanat' => 2069,
    'Littérature' => 2210,
    'Historique' => 2206,
    'Œnologie' => 2271
}

APIDAE_CATEGORIES = {
    'Démonstration' => 3871,
    'Atelier' => 2119,
    'Jeux' => 2112,
    'Visite guidée' => 2101,
    'Concert' => 2128,
    'Conférence / Débat' => 2072,
    'Exposition' => 2080,
    'Projection' => 3818,
    'Spectacle' => 2091,
    'Dégustation' => 3717,
    'Goûter' => 2123,
    'Marché' => 2083,
    'Théâtre' => 2134,
    'Danse' => 2151,
    "Visite d'un site / monument" => 4546
}

APIDAE_COVID_DESC = 6143

TERRITORIES = {
    GRAND_LYON => {
        'Ouest' => ['69410', '69260', '69290', '69570', '69130', '69340', '69890', '69760', '69380', '69280', '69450',
                    '69370', '69290', '69160'],
        'Nord' => ['69250', '69270', '69300', '69660', '69270', '69250', '69250', '69270', '69270', '69730', '69250',
                   '69250', '69250', '69650', '69140', '69270', '69650', '69270', '69580', '69580'],
        'Est' => ['69500', '69680', '69150', '69330', '69330', '69780', '69800', '69120'],
        'Sud' => ['69390', '69960', '69320', '69700', '69520', '69540', '69350', '69600', '69310', '69110', '69190',
                  '69230', '69360', '69200', '69390'],
        'Villeurbanne' => ['69100'],
        'Lyon' => ['69001', '69002', '69003', '69004', '69005', '69006', '69007', '69008', '69009']
    },
    ISERE => {
        'Agglomération Grenobloise' => ['38320', '38800', '38560', '38640', '38700', '38420', '38130', '38600', '38120', 
                                        '38610', '38000', '38450', '38240', '38220', '38360', '38950', '38400', '38760', 
                                        '38170', '38180', '38410', '38113'], 
        'Bièvre Valloire'=> ['38140', '38260', '38270', '38690', '38870', '38590', '38122', '38980', '38940'],
        'Condrieu' => ['69420', '69560', '69700'],
        'Grésivaudan' => ['38580', '38530', '38190', '38330', '38410', '38830', '38920', '38570', '38660', '38420'],
        'Haut Rhône Dauphinois' => ['38460', '38280', '38510', '38390', '38230', '38630', '38290', '38118', '38890'],
        'Isère rhodanienne' => ['38150', '38550', '38670', '38121', '38200', '38780', '38138', '38370', '38440'],
        'Matheysine' => ['38970', '38740', '38220', '38350', '38770', '38144', '38119'],
        'Oisans' => ['38114', '38142', '38520', '38750', '38220', '38860'],
        'Porte des Alpes' => ['38440', '38090', '38300', '38790', '38080', '38540', '38290', '38890', '38780', '38460',
                            '38070'], 
        'Sud Grésivaudan' => ['38680', '38470', '38160', '38210', '38840'],
        'Trièves' => ['38650', '38710', '38930'],
        'Vals du Dauphiné' => ['38490', '38690', '38730', '38110', '38480'],
        'Vercors' => ['38112', '38250', '38360', '38880'],
        'Voironnais-Chartreuse' => ['38850', '38490', '38140', '38500', '38380', '38340', '38620', '38430', '38960',
                                  '38134', '73670', '38210']
    },
    SAUMUR => {},
    DLVA => {}
}

TERRITORIES_BY_CODE = Hash[TERRITORIES.collect {|k, v| [k, Hash[*v.invert.collect {|codes, t| codes.collect {|code| [code, t]}}.flatten]]}]

ISERE_TERRITORIES = {
    'Agglomération Grenobloise' => ['38057', '38059', '38068', '38071', '38111', '38126', '38150', '38151', '38158', '38169', '38170', '38179', '38185', '38187', '38188', '38200', '38229', '38235', '38252', '38258', '38271', '38277', '38279', '38281', '38309', '38317', '38325', '38328', '38364', '38382', '38388', '38421', '38423', '38436', '38445', '38471', '38472', '38474', '38478', '38485', '38486', '38516', '38524', '38528', '38529', '38533', '38540', '38545', '38562'],
    'Bièvre Valloire' => ['38013', '38030', '38032', '38034', '38037', '38042', '38046', '38049', '38056', '38058', '38060', '38063', '38065', '38066', '38069', '38093', '38118', '38130', '38134', '38159', '38161', '38167', '38171', '38174', '38190', '38182', '38194', '38198', '38209', '38216', '38218', '38219', '38221', '38240', '38244', '38255', '38259', '38267', '38284', '38287', '38290', '38291', '38300', '38307', '38308', '38311', '38324', '38332', '38335', '38347', '38363', '38379', '38380', '38384', '38387', '38393', '38406', '38427', '38437', '38440', '38457', '38473', '38479', '38490', '38505', '38561'],
    'Grésivaudan' => ['38002', '38006', '38027', '38039', '38045', '38062', '38070', '38567', '38075', '38078', '38100', '38120', '38140', '38163', '38166', '38175', '38181', '38192', '38206', '38214', '38249', '38268', '38303', '38314', '38334', '38350', '38395', '38397', '38404', '38417', '38418', '38422', '38426', '38430', '38431', '38439', '38466', '38501', '38503', '38504', '38511', '38538', '38547'],
    'Haut Rhône Dauphinois' => ['38010', '38011', '38022', '38026', '38050', '38054', '38055', '38067', '38083', '38085', '38097', '38109', '38124', '38135', '38138', '38139', '38146', '38176', '38190', '38197', '38210', '38247', '38260', '38261', '38282', '38294', '38295', '38297', '38316', '38320', '38365', '38451', '38458', '38465', '38483', '38488', '38494', '38507', '38525', '38535', '38539', '38542', '38543', '38554', '38557'],
    'Isère rhodanienne' => ['38003', '38009', '38017', '38019', '38051', '38072', '38077', '38087', '38101', '38107', '38110', '38114', '38131', '38157', '38160', '38199', '38215', '38238', '38298', '38318', '38336', '38340', '38344', '38349', '38353', '38378', '38425', '38448', '38452', '38459', '38468', '38480', '38484', '38487', '38496', '38536', '38544', '38556', '38558', '69064', '69007', '69097', '69119', '69189', '69193', '69235', '69118', '69080', '69236'],
    'Matheysine' => ['38008', '38031', '38073', '38106', '38116', '38128', '38132', '38154', '38203', '38207', '38217', '38224', '38241', '38254', '38264', '38265', '38266', '38269', '38273', '38280', '38283', '38299', '38304', '38313', '38326', '38329', '38361', '38396', '38402', '38413', '38414', '38428', '38444', '38462', '38469', '38470', '38489', '38497', '38499', '38518', '38521', '38522', '38552'],
    'Oisans' => ['38005', '38020', '38040', '38052', '38112', '38173', '38177', '38191', '38212', '38237', '38253', '38285', '38286', '38289', '38375', '38527', '38549', '38550', '38551'],
    'Porte des Alpes' => ['38015', '38035', '38048', '38053', '38081', '38091', '38094', '38102', '38136', '38141', '38144', '38149', '38152', '38156', '38172', '38184', '38189', '38193', '38211', '38223', '38230', '38231', '38232', '38250', '38276', '38288', '38339', '38346', '38348', '38351', '38352', '38358', '38374', '38389', '38392', '38399', '38408', '38415', '38449', '38455', '38467', '38475', '38476', '38481', '38498', '38512', '38515', '38519', '38530', '38532', '38537', '38546', '38553', '38555'],
    'Sud Grésivaudan' => ['26270', '38004', '38018', '38033', '38036', '38041', '38074', '38086', '38092', '38095', '38099', '38108', '38117', '38137', '38195', '38216', '38245', '38248', '38263', '38272', '38275', '38278', '38310', '38319', '38322', '38330', '38333', '38338', '38345', '38356', '38359', '38360', '38370', '38390', '38394', '38409', '38410', '38416', '38443', '38450', '38453', '38454', '38463', '38495', '38500', '38523', '38526', '38559'],
    'Trièves' => ['38023', '38090', '38103', '38113', '38115', '38127', '38186', '38204', '38208', '38226', '38242', '38243', '38301', '38321', '38342', '38355', '38366', '38391', '38403', '38419', '38424', '38429', '38438', '38456', '38492', '38513', '38514'],
    'Vals du Dauphiné' => ['38001', '38012', '38029', '38038', '38044', '38047', '38064', '38076', '38089', '38098', '38104', '38147', '38148', '38162', '38183', '38246', '38257', '38296', '38315', '38323', '38341', '38343', '38354', '38357', '38369', '38377', '38381', '38398', '38401', '38420', '38434', '38464', '38508', '38509', '38520', '38560'],
    'Vercors' => ['38129', '38153', '38205', '38225', '38433', '38548'],
    'Voironnais-Chartreuse' => ['38043', '38061', '38080', '38082', '38084', '38105', '38133', '38155', '38222', '38228', '38236', '38239', '38256', '38270', '38292', '38331', '38337', '38362', '38368', '38372', '38373', '38376', '38383', '38386', '38400', '38405', '38407', '38412', '38432', '38442', '38446', '38460', '38517', '38531', '38563', '38564', '38565', '38566', '73092']
}