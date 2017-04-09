GRAND_LYON = "grand_lyon"
ISERE = "isere"

ITEM_VISITE = "visite"
ITEM_PARCOURS = "parcours"
ITEM_ANIMATION = "animation"
ITEM_EXPOSITION = "exposition"

ITEM_TYPES = [ITEM_VISITE, ITEM_PARCOURS, ITEM_ANIMATION, ITEM_EXPOSITION]

THEMES = {
    GRAND_LYON => ["Thématique 2017", "La Métropole au fil de l'eau", "Nouveauté", "En famille", "Jeunes (15-25 ans)", "Egalité"],
    ISERE => ["Thématique 2017", "Famille", "Réservé aux enfants", "Antiquité", "Archéologie", "Architecture", "Art contemporain", "Artisanat", "Littérature"]
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

ACCESSIBILITY = {
    GRAND_LYON => ["Personnes à mobilité réduite (accès total)", "Personnes à mobilité réduite (accès partiel)",
                   "Personnes malentendantes ou sourdes", "Personnes malvoyantes ou non voyantes",
                   "Non accessible en fauteuil roulant"],
    ISERE => ["Personnes à mobilité réduite (accès total)", "Personnes à mobilité réduite (accès partiel)",
                   "Personnes malentendantes ou sourdes", "Personnes malvoyantes ou non voyantes",
                   "Non accessible en fauteuil roulant"]
}