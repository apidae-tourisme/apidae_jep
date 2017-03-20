GRAND_LYON = "grand_lyon"
ISERE = "isere"

ITEM_VISITE = "visite"
ITEM_PARCOURS = "parcours"
ITEM_ANIMATION = "animation"
ITEM_EXPOSITION = "exposition"

ITEM_TYPES = [ITEM_VISITE, ITEM_PARCOURS, ITEM_ANIMATION, ITEM_EXPOSITION]

THEMES = {
    GRAND_LYON => ["Thématique 2017", "La Métropole au fil de l'eau", "Nouveauté", "Egalité", "Patrimoine industriel"]
}

CRITERIA = {
    GRAND_LYON => {
      ITEM_VISITE => ["Visite guidée", "Visite libre"],
      ITEM_PARCOURS => ["Croisière", "En bus", "En vélo"],
      ITEM_ANIMATION => ["Théâtre", "Concert", "Danse", "Lecture", "Conte", "Conférence / Débat", "Projection",
                         "Démonstration", "Dégustations", "Jeux", "Atelier"],
      ITEM_EXPOSITION => ["Conférence / Débat", "Projection"]
    }
}

ACCESSIBILITY = {
    GRAND_LYON => ["Accès PMR", "L.S.F.", "Accès Mal-voyants"]
}