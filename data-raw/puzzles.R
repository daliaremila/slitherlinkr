
# Script de generation des grilles d'exemple
# Execute une seule fois pour creer les fichiers dans data/

# ---- Grille facile : 3 x 4 ----
puzzle_easy <- slitherlinkr::new_puzzle(
  matrix(c(NA, 3, NA, 2,
           2, NA, 1, NA,
           NA, 0, NA, 3), nrow = 3, byrow = TRUE)
)

# ---- Grille moyenne : 5 x 5 ----
puzzle_medium <- slitherlinkr::new_puzzle(
  matrix(c(NA,  2,  2, NA, NA,
           NA, NA, NA,  3,  2,
           NA, NA, NA, NA,  1,
           3,  0, NA, NA,  2,
           NA,  3,  2,  2, NA), nrow = 5, byrow = TRUE)
)

# ---- Grille difficile : 7 x 7 ----
puzzle_hard <- slitherlinkr::new_puzzle(
  matrix(c(NA,  3, NA, NA,  2, NA, NA,
           2, NA, NA,  1, NA, NA,  3,
           NA, NA,  3, NA,  2, NA, NA,
           1, NA, NA,  2, NA, NA,  2,
           NA, NA,  3, NA,  1, NA, NA,
           3, NA, NA,  2, NA, NA,  0,
           NA, NA, NA, NA,  3,  2, NA), nrow = 7, byrow = TRUE)
)

# Sauvegarder dans data/
usethis::use_data(puzzle_easy, puzzle_medium, puzzle_hard, overwrite = TRUE)
