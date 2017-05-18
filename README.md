# ApidaeJEP

## A propos d'ApidaeJEP
ApidaeJEP est un outil de saisie d'événements développé pour le réseau Apidae dans le cadre des Journées Européennes du Patrimoine.

L'outil comporte 2 accès distincts :

  - Un accès en saisie pour les personnes qui organisent les événements
  - Un accès en validation pour les équipes de modération qui valident et enrichissent les saisies au besoin

A l'issue de la validation, les événements sont poussés dans la base de données touristique Apidae.


## Prérequis
  - Un serveur web pouvant héberger une application Ruby on Rails (Apache avec mod Passenger par exemple)
  - Une base de données standard (Postgres 9.X par défaut)
  - Un projet en écriture Apidae

Le projet utilise également la fonctionnalité Apidae connect pour l'authentification des utilisateurs. Cette fonction requiert d'avoir un projet de type SSO paramétré sur la plateforme Apidae Tourisme.
