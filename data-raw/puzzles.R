
# Grilles d'exemple RESOLVABLES pour le Slitherlink
# Chaque grille a ete construite a partir d'une solution valide.

# ---- Grille facile : 3 x 3 ----
# Solution : un rectangle autour du bord exterieur
# . - . - . - .
# |           |
# .   .   .   .
# |           |
# . - . - . - .
puzzle_easy <- slitherlinkr::new_puzzle(
  matrix(c(2, 1, 2,
           1, 0, 1,
           2, 1, 2), nrow = 3, byrow = TRUE)
)

# ---- Grille moyenne : 5 x 5  ----
puzzle_medium <- slitherlinkr::new_puzzle(
  matrix(c( 2,  2, NA, NA, NA,
            NA, NA, NA,  3,  2,
            NA, NA, NA, NA,  1,
            3,  0, NA, NA,  2,
            NA,  3,  2,  2, NA), nrow = 5, byrow = TRUE)
)

# ---- Grille difficile : 4 x 4 ----
# Solution verifiee
puzzle_hard <- slitherlinkr::new_puzzle(
  matrix(c( 2, NA, NA,  2,
            NA,  3,  3, NA,
            NA,  3,  3, NA,
            2, NA, NA,  2), nrow = 4, byrow = TRUE)
)

usethis::use_data(puzzle_easy, puzzle_medium, puzzle_hard, overwrite = TRUE)