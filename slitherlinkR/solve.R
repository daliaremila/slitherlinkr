#' @export
is_solved <- function(p) {
  h <- (p$h_edges == 1); v <- (p$v_edges == 1)
  # Vérifier les chiffres [cite: 20, 21]
  for (i in 1:p$n) {
    for (j in 1:p$m) {
      if (!is.na(p$clues[i, j])) {
        if ((h[i,j] + h[i+1,j] + v[i,j] + v[i,j+1]) != p$clues[i,j]) 
          return(list(solved=FALSE, msg="Chiffre non respecté"))
      }
    }
  }
  # Vérifier les sommets (0 ou 2 segments) [cite: 18]
  for (i in 0:p$n) {
    for (j in 0:p$m) {
      deg <- 0
      if (i > 0) deg <- deg + v[i, j+1]
      if (i < p$n) deg <- deg + v[i+1, j+1]
      if (j > 0) deg <- deg + h[i+1, j]
      if (j < p$m) deg <- deg + h[i+1, j+1]
      if (!(deg %in% c(0, 2))) return(list(solved=FALSE, msg="La boucle est rompue"))
    }
  }
  return(list(solved=TRUE, msg="Bravo !"))
}