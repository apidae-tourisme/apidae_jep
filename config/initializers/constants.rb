GRAND_LYON = "grand_lyon"
ISERE = "isere"

ITEM_VISITE = "visite"
ITEM_PARCOURS = "parcours"
ITEM_ANIMATION = "animation"
ITEM_EXPOSITION = "exposition"

ITEM_TYPES = [ITEM_VISITE, ITEM_PARCOURS, ITEM_ANIMATION, ITEM_EXPOSITION]

THEMES = {
    GRAND_LYON => ['Thématique 2017 - "Jeunesse et Patrimoine"', "La Métropole au fil de l'eau", "Nouveauté", "En famille", "Jeunes (15-25 ans)", "Egalité"],
    ISERE => ['Thématique 2017 - "Jeunesse et Patrimoine"', "Famille", "Réservé aux enfants", "Antiquité", "Archéologie", "Architecture", "Art contemporain", "Artisanat", "Littérature"]
}
THEMES_REFS = Hash[THEMES.values.flatten.collect {|th| [th.parameterize, th] }]

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

ALL_REFS = THEMES_REFS.merge(CRITERIA_REFS).merge(ACCESSIBILITY_REFS)

# Prod
APIDAE_CRITERIA = {
    'Nouveauté' => 7997,
    "Visite libre" => 10173,
    "La Métropole au fil de l'eau" => 10160,
    'Egalité' => 10161,
    'animation' => 10171,
    'parcours' => 10172
}

APIDAE_TYPOLOGIES = {
    'Thématique 2017 - "Jeunesse et Patrimoine"' => 5133
}

# Preprod
# APIDAE_CRITERIA = {
#     'Nouveauté' => 7997,
#     "Visite libre" => 8767,
#     "La Métropole au fil de l'eau" => 8776,
#     'Egalité' => 8777,
#     'animation' => 8769,
#     'parcours' => 8768
# }
#
# APIDAE_TYPOLOGIES = {
#     'Thématique 2017 - "Jeunesse et Patrimoine"' => 4927
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
    'Littérature' => 2210
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
