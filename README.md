# 🧩 slitherlinkr

**Projet R & Shiny — Université de Montpellier**

`slitherlinkr` est une bibliothèque R accompagnée d’une application Shiny interactive pour le jeu de logique **Slitherlink**.  
Ce projet a été réalisé dans le cadre du module de programmation R dirigé par Jean‑Michel Marin.

---

## 🚀 Lancement rapide

Pour lancer directement l’application Shiny :

```r
shiny::runGitHub("slitherlinkr", "daliaremila", ref = "main")
```

---

## 🎯 Objectif du projet

L’objectif est de concevoir un **moteur de jeu Slitherlink** capable de :

- Générer des grilles de différentes tailles.
- Gérer les interactions utilisateur (tracés de lignes et croix).
- Vérifier automatiquement la validité de la solution.

---

## 🛠️ Méthodologie

### 🔹 Modélisation mathématique

Le jeu est modélisé comme un **graphe** :

\[
G = (V,E)
\]

où :
- \(V\) représente l’ensemble des **sommets**.
- \(E\) représente l’ensemble des **arêtes**.

### Contraintes du jeu

- **Contrainte de degré** :  
  Pour tout sommet \(v \in V\), son degré doit être 0 ou 2 :
  $\forall v \in V,\quad d(v) \in \{0, 2\}$

- **Contrainte de face** (par case) :  
  Chaque case contient un indice \(n\) indiquant le nombre d’arêtes actives autour de la case.  
  On vérifie que le nombre de segments actifs autour de la case est exactement égal à \(n\).

- **Boucle unique** :  
  La solution doit former **une seule boucle fermée**, vérifiée via un parcours de graphe (par exemple, DFS ou BFS) sur les arêtes actives.

---

## 🔹 Interface et algorithmes

### Détection des clics

L'application calcule la distance euclidienne entre le clic utilisateur et le segment le plus proche :

$$
d = \sqrt{(x - x_u)^2 + (y - y_u)^2}
$$

où $(x_u, y_u)$ est la position du clic et $(x, y)$ représente les coordonnées d'un segment.

### Gestion de l’état

L’état de la grille (segments actifs, croix, indices, etc.) est géré via :

```r
reactiveValues()
```

### Mise à jour dynamique

L’interface s’appuie sur la **réactivité Shiny** pour mettre à jour la grille sans rechargement de page.

---

## 📚 Technologies utilisées

- `shiny` → Application web interactive.
- `ggplot2` → Rendu graphique de la grille.
- `dplyr` → Manipulation des données (grille, arêtes, états).
- `grid` → Gestion graphique avancée (si nécessaire).

---

## 🎮 Fonctionnement de l'application

### 🔢 Niveaux

| Taille   | Difficulté |
|---------|-----------|
| 3 × 3   | Facile    |
| 5 × 5   | Moyen     |
| 7 × 7   | Difficile |

L’utilisateur peut choisir le niveau dans l’interface.

### 🎛️ Modes de jeu

- **Mode Ligne** : permet de tracer la boucle (valider une arête).
- **Mode Croix** : permet d’exclure une arête (marquer qu’elle ne fait pas partie de la solution).

### ✅ Vérification

Un bouton **“Vérifier”** permet de tester si :

- Toutes les contraintes locales (cases) sont respectées.
- Les contraintes de degré sur les sommets sont satisfaites.
- La solution forme une **unique boucle fermée**.
- Aucun segment invalide n’est présent.

L’algorithme affiche un message de succès ou échec selon le résultat.

---

## 🧠 Logique de résolution (résumé)

À chaque vérification, l’application effectue :

1. **Vérification des contraintes locales (cases)** :  
   Compte le nombre d’arêtes actives autour de chaque case et les compare à l’indice \(n\).

2. **Vérification des degrés des sommets** :  
   Pour chaque sommet, vérifie que $d(v) \in \{0, 2\}$

3. **Vérification de la connectivité (boucle unique)** :  
   Effectue un parcours de graphe (DFS ou BFS) sur les arêtes actives pour vérifier qu’il n’y a **qu’une seule composante connexe**.

4. **Validation ou rejet** :  
   Si toutes les conditions sont satisfaites, la solution est validée ; sinon, un message d’erreur est affiché.

---

---

## ✨ Améliorations possibles

- **Génération automatique de grilles** :  
  Ajouter un générateur de puzzles aléatoires respectant les contraintes.

- **Ajout d’un solveur intelligent** :  
  Implémenter un algorithme de résolution automatique (backtracking, CSP, etc.).

- **Interface plus intuitive** :  
  - Hover pour surligner les segments voisins.  
  - Aperçu interactif de la prochaine action.

- **Mode mobile optimisé** :  
  Adapter la mise en page et les interactions pour écrans tactiles.

## 📂 Structure du projet
.
├── R/ # Logique du jeu (fonctions manipulant la grille, états, vérifications)
├── data/ # Puzzles prédéfinis
├── app.R # Application Shiny (interface + réactivité)
├── DESCRIPTION # Métadonnées du package R

## 👤 Auteurs

Ce projet a été réalisé par :

- **Dalia Remila**  
- **Aly Dahoud**

dans le cadre du module de programmation R à l’Université de Montpellier, encadré par Jean‑Michel Marin.

