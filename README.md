🧩 Slitherlink Expert - Projet R & Shiny (UM)

Ce projet consiste en la création d'une bibliothèque R et d'une application Shiny interactive pour le jeu de logique Slitherlink.
Ce travail a été réalisé dans le cadre du module de programmation R dirigé par Jean-Michel Marin à l'Université de Montpellier.

🚀 Lancement rapide

Pour tester l'application avec la version la plus récente, exécutez la commande suivante dans votre console R :

shiny::runGitHub("slitherlinkr", "daliaremila", ref = "main")
🎯 But du projet

L'objectif était de concevoir un moteur de jeu complet capable de :

Générer et afficher des grilles de Slitherlink de différentes tailles
Gérer les interactions utilisateurs (clics pour tracer des lignes ou placer des croix)
Vérifier la validité de la solution selon les règles mathématiques du jeu
🛠️ Méthodologie

Le projet a été structuré comme un package R afin de garantir la modularité et la maintenabilité du code.

1. Modélisation mathématique

Le Slitherlink est modélisé comme un problème de recherche de cycle unique dans un graphe grille :

G=(V,E)
Contrainte de degré : chaque sommet v doit avoir un degré d(v)∈{0,2}
Contrainte de face : pour chaque case avec un indice n, la somme des arêtes activées autour doit être égale à n
Théorème de Jordan : un algorithme de parcours de graphe vérifie qu'il existe une seule composante connexe (une seule boucle)
2. Algorithmes de l'interface
Détection de proximité :
Calcul de la distance euclidienne entre le clic utilisateur (x
u
	​

,y
u
	​

) et le milieu de chaque segment pour identifier l’arête sélectionnée
Gestion d’état :
Utilisation de reactiveValues pour stocker l’état du jeu et permettre une mise à jour instantanée sans rechargement
📚 Bibliothèques utilisées

Le projet s'appuie sur l'écosystème Tidyverse et Shiny :

shiny : structure de l'application web et gestion de la réactivité
ggplot2 : rendu graphique de la grille
geom_segment() pour les lignes
geom_text() pour les indices
dplyr : manipulation des données
grid : gestion fine des unités graphiques
🎮 Fonctionnement de l'application
Sélection du niveau :
3x3 (facile)
5x5 (moyen)
7x7 (difficile)
Outils de jeu :
Mode Ligne : tracer les segments de la boucle
Mode Croix : marquer les arêtes vides
Vérification :
Un bouton analyse la grille et confirme si toutes les contraintes sont respectées
📂 Structure du dépôt
.
├── R/            # Logique du jeu et fonctions
├── data/         # Données des puzzles
├── app.R         # Application Shiny (point d’entrée)
├── DESCRIPTION   # Métadonnées du package
👩‍💻 Auteur

Dalia Remila

🎓 Université : Montpellier (UM)
📅 Date : 17 Avril 2026
