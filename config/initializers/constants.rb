GRAND_LYON = "grand_lyon"
ISERE = "isere"

ITEM_VISITE = "visite"
ITEM_PARCOURS = "parcours"
ITEM_ANIMATION = "animation"
ITEM_EXPOSITION = "exposition"

ITEM_TYPES = [ITEM_VISITE, ITEM_PARCOURS, ITEM_ANIMATION, ITEM_EXPOSITION]

THEMES = {
    GRAND_LYON => ["Thématique 2018 - \"L'art du partage\"", "Unesco", "Nouveauté",
                   "En famille", "Jeunes (15-25 ans)", "Egalité"],
    ISERE => ["Thématique 2018 - \"L'art du partage\"", "Famille", "Réservé aux enfants", "Antiquité",
              "Archéologie", "Architecture", "Art contemporain", "Artisanat", "Littérature", "Historique"]
}
THEMES_REFS = Hash[THEMES.values.flatten.collect {|th| [th.parameterize, th] }]

VALIDATION_CRITERIA = {
    GRAND_LYON => ['Coup de coeur', 'Visites guidées de l\'Office du Tourisme', 'Balades urbaines du Musée Gadagne',
                   'Sous-thématique 1', 'Sous-thématique 2', 'Sous-thématique 3', 'Sous-thématique 4', 'Sous-thématique 5'],
    ISERE => []
}
VALIDATION_CRITERIA_REFS = Hash[VALIDATION_CRITERIA.values.flatten.collect {|th| [th.parameterize, th] }]

CRITERIA = {
    GRAND_LYON => {
      ITEM_VISITE => ["Visite guidée", "Visite libre"],
      ITEM_PARCOURS => ["Parcours", "Croisière", "Visite guidée", "Visite libre"],
      ITEM_ANIMATION => {
          "Intervention artistique" => ["Théâtre", "Concert", "Danse", "Lecture", "Conte"],
          "Conférence / Débat / Projection" => ["Conférence / Débat", "Projection"],
          "Savoirs-faire" => ["Démonstration", "Dégustations"],
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
    }
}
ACCESSIBILITY_REFS = ACCESSIBILITY.values.inject(:merge)

ALL_REFS = THEMES_REFS.merge(VALIDATION_CRITERIA_REFS).merge(CRITERIA_REFS).merge(ACCESSIBILITY_REFS)

# Prod
APIDAE_CRITERIA = {
    'Nouveauté' => 7997,
    "Visite libre" => 10173,
    "Unesco" => 10160,
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
    'Balades urbaines du Musée Gadagne' => 8292
}

APIDAE_TYPOLOGIES = {
    "Thématique 2018 - \"L'art du partage\"" => 5412
}

# Preprod
# APIDAE_CRITERIA = {
#     'Nouveauté' => 7997,
#     "Visite libre" => 8767,
#     "Unesco" => 8776,
#     'Egalité' => 8777,
#     'animation' => 8769,
#     'parcours' => 8768,
#     'Sous-thématique 1' => 8771,
#     'Sous-thématique 1' => 8772,
#     'Sous-thématique 1' => 8773,
#     'Sous-thématique 1' => 8774,
#     'Sous-thématique 1' => 8775,
#     'Coup de coeur' => 7998,
#     'Visites guidées de l\'Office du Tourisme' => 8778,
#     'Balades urbaines du Musée Gadagne' => 8292
# }
#
# APIDAE_TYPOLOGIES = {
#     "Thématique 2018 - \"L'art du partage\"" => 4927
# }

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
    'Historique' => 2206
}

APIDAE_CATEGORIES = {
    'Démonstration' => 3871,
    'Atelier' => 2119,
    'Jeux' => 2112,
    'Visite guidée' => 2101,
    'Concert' => 2128,
    'Conférence' => 2072,
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
        'Bièvre Valloire'=>['38140', '38260', '38270', '38690', '38870', '38590', '38122', '38980', '38940'], 
        'Grésivaudan'=>['38580', '38530', '38190', '38330', '38410', '38830', '38920', '38570', '38660', '38420'], 
        'Haut Rhône Dauphinois'=>['38460', '38280', '38510', '38390', '38230', '38630', '38290', '38118', '38890'], 
        'Isère rhodanienne'=>['38150', '38550', '38670', '38121', '38200', '38780', '38138', '38370', '38440'], 
        'Matheysine'=>['38970', '38740', '38220', '38350', '38770', '38144', '38119'], 
        'Oisans'=>['38114', '38142', '38520', '38750', '38220', '38860'], 
        'Porte des Alpes'=>['38440', '38090', '38300', '38790', '38080', '38540', '38290', '38890', '38780', '38460', 
                            '38070'], 
        'Sud Grésivaudan'=>['38680', '38470', '38160', '38210', '38840'], 
        'Trièves'=>['38650', '38710', '38930'], 
        'Vals du Dauphiné'=>['38490', '38690', '38730', '38110', '38480'], 
        'Vercors'=>['38112', '38250', '38360'], 
        'Voironnais-Chartreuse'=>['38850', '38490', '38140', '38500', '38380', '38340', '38620', '38430', '38960', 
                                  '38134', '73670', '38210']
    }
}

TERRITORIES_BY_CODE = Hash[TERRITORIES.collect {|k, v| [k, Hash[*v.invert.collect {|codes, t| codes.collect {|code| [code, t]}}.flatten]]}]