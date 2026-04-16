#' Creer un puzzle Slitherlink
#'
#' Construit un objet de classe `slitherlink` a partir d'une matrice
#' d'indices. Les aretes (horizontales et verticales) sont initialisees
#' a 0 (non tracees).
#'
#' @param clues Une matrice `n x m` d'entiers entre 0 et 3, avec `NA`
#'   pour les cases sans indice.
#'
#' @return Un objet de classe `slitherlink`, qui est une liste contenant :
#'   \describe{
#'     \item{clues}{La matrice d'indices.}
#'     \item{h_edges}{Matrice `(n+1) x m` des aretes horizontales (0/1).}
#'     \item{v_edges}{Matrice `n x (m+1)` des aretes verticales (0/1).}
#'     \item{n}{Nombre de lignes de cases.}
#'     \item{m}{Nombre de colonnes de cases.}
#'   }
#'
#' @examples
#' clues <- matrix(c(NA, 3, NA, 2,
#'                   2, NA, 1, NA,
#'                   NA, 0, NA, 3), nrow = 3, byrow = TRUE)
#' p <- new_puzzle(clues)
#' p
#'
#' @export
new_puzzle <- function(clues) {
  # Verifications de base
  if (!is.matrix(clues)) {
    stop("'clues' doit etre une matrice.")
  }
  valeurs <- as.vector(clues)
  valeurs <- valeurs[!is.na(valeurs)]
  if (any(valeurs < 0) || any(valeurs > 3) || any(valeurs != floor(valeurs))) {
    stop("'clues' ne doit contenir que des entiers 0-3 ou NA.")
  }
  
  n <- nrow(clues)
  m <- ncol(clues)
  
  # Aretes initialisees a 0 (non tracees)
  h_edges <- matrix(0L, nrow = n + 1, ncol = m)
  v_edges <- matrix(0L, nrow = n, ncol = m + 1)
  
  puzzle <- list(
    clues   = clues,
    h_edges = h_edges,
    v_edges = v_edges,
    n       = n,
    m       = m
  )
  class(puzzle) <- "slitherlink"
  puzzle
}
#' Basculer l'etat d'une arete
#' @param p Un objet slitherlink
#' @param type "h" ou "v"
#' @param r,c Coordonnees de l'arete
#' @export
toggle_edge <- function(p, type, r, c) {
  if (type == "h") {
    p$h_edges[r, c] <- 1L - p$h_edges[r, c]
  } else {
    p$v_edges[r, c] <- 1L - p$v_edges[r, c]
  }
  p
}

#' Methode print pour les objets slitherlink
#'
#' Affiche un resume compact d'un puzzle Slitherlink : dimensions,
#' nombre d'indices, et nombre d'aretes actuellement tracees.
#'
#' @param x Un objet de classe `slitherlink`.
#' @param ... Arguments supplementaires (non utilises).
#'
#' @return Retourne invisiblement `x`.
#'
#' @export
print.slitherlink <- function(x, ...) {
  cat("Puzzle Slitherlink\n")
  cat("  Dimensions       :", x$n, "x", x$m, "cases\n")
  cat("  Nombre d'indices :", sum(!is.na(x$clues)), "\n")
  cat("  Aretes tracees   :", sum(x$h_edges) + sum(x$v_edges),
      "/", length(x$h_edges) + length(x$v_edges), "\n")
  invisible(x)
}
#' Basculer l'etat d'une arete
#'
#' @param p Un objet de classe `slitherlink`.
#' @param type Caractere, "h" pour une arete horizontale, "v" pour une verticale.
#' @param r Indice de la ligne.
#' @param c Indice de la colonne.
#'
#' @return L'objet `slitherlink` avec l'arete modifiee.
#' @export
toggle_edge <- function(p, type, r, c) {
  if (type == "h") {
    p$h_edges[r, c] <- 1L - p$h_edges[r, c]
  } else {
    p$v_edges[r, c] <- 1L - p$v_edges[r, c]
  }
  p
}


