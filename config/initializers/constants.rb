GRAND_LYON = "grand_lyon"
ISERE = "isere"

ITEM_VISITE = "visite"
ITEM_PARCOURS = "parcours"
ITEM_ANIMATION = "animation"
ITEM_EXPOSITION = "exposition"

ITEM_TYPES = [ITEM_VISITE, ITEM_PARCOURS, ITEM_ANIMATION, ITEM_EXPOSITION]

THEMES = {
    GRAND_LYON => ["Thématique 2017", "La Métropole au fil de l'eau", "Nouveauté", "En famille", "Jeunes (15-25 ans)", "Egalité"],
    ISERE => []
}

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
      ITEM_EXPOSITION => ["Exposition", "Visite guidée", "Visite libre"]
    }
}

ACCESSIBILITY = {
    GRAND_LYON => ["Personnes à mobilité réduite (accès total)", "Personnes à mobilité réduite (accès partiel)",
                   "Personnes malentendantes ou sourdes", "Personnes malvoyantes ou non voyantes",
                   "Non accessible en fauteuil roulant"]
}