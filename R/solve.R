#' Verifier si un puzzle Slitherlink est resolu
#'
#' Verifier les trois regles du Slitherlink :
#' 1. Chaque indice de case est respecte (nombre d'aretes tracees
#'    autour de la case = indice).
#' 2. A chaque point, il y a exactement 0 ou 2 aretes incidentes.
#' 3. Les aretes tracees forment une seule boucle fermee.
#'
#' @param puzzle Un objet de classe `slitherlink`.
#'
#' @return Une liste contenant :
#'   \describe{
#'     \item{solved}{`TRUE` si les trois conditions sont remplies.}
#'     \item{clues_ok}{`TRUE` si tous les indices sont respectes.}
#'     \item{vertices_ok}{`TRUE` si tous les points ont 0 ou 2 aretes.}
#'     \item{single_loop}{`TRUE` si les aretes forment une seule boucle.}
#'     \item{bad_clues}{Matrice booleenne aux cases dont l'indice est viole.}
#'     \item{bad_vertices}{Matrice booleenne aux points fautifs.}
#'     \item{n_loops}{Nombre de composantes connexes d'aretes.}
#'   }
#'
#' @examples
#' clues <- matrix(c(NA, 3, NA, 2,
#'                   2, NA, 1, NA,
#'                   NA, 0, NA, 3), nrow = 3, byrow = TRUE)
#' p <- new_puzzle(clues)
#' is_solved(p)
#'
#' @export
is_solved <- function(puzzle) {
  if (!inherits(puzzle, "slitherlink")) {
    stop("'puzzle' doit etre un objet de classe 'slitherlink'.")
  }
  
  n <- puzzle$n
  m <- puzzle$m
  h <- puzzle$h_edges
  v <- puzzle$v_edges
  
  # --- 1. Verification des indices ---
  bad_clues <- matrix(FALSE, nrow = n, ncol = m)
  for (i in 1:n) {
    for (j in 1:m) {
      if (!is.na(puzzle$clues[i, j])) {
        count <- h[i, j] + h[i + 1, j] + v[i, j] + v[i, j + 1]
        if (count != puzzle$clues[i, j]) {
          bad_clues[i, j] <- TRUE
        }
      }
    }
  }
  clues_ok <- !any(bad_clues)
  
  # --- 2. Verification des sommets ---
  bad_vertices <- matrix(FALSE, nrow = n + 1, ncol = m + 1)
  for (i in 0:n) {
    for (j in 0:m) {
      count <- 0
      if (i >= 1)       count <- count + v[i, j + 1]
      if (i <= n - 1)   count <- count + v[i + 1, j + 1]
      if (j >= 1)       count <- count + h[i + 1, j]
      if (j <= m - 1)   count <- count + h[i + 1, j + 1]
      if (!(count == 0 || count == 2)) {
        bad_vertices[i + 1, j + 1] <- TRUE
      }
    }
  }
  vertices_ok <- !any(bad_vertices)
  
  # --- 3. Comptage des boucles ---
  n_loops <- .count_loops(h, v, n, m)
  single_loop <- (n_loops == 1)
  
  solved <- clues_ok && vertices_ok && single_loop
  
  list(
    solved       = solved,
    clues_ok     = clues_ok,
    vertices_ok  = vertices_ok,
    single_loop  = single_loop,
    bad_clues    = bad_clues,
    bad_vertices = bad_vertices,
    n_loops      = n_loops
  )
}


# Fonction interne : compte les composantes connexes formees
# par les aretes tracees (via Union-Find).
.count_loops <- function(h, v, n, m) {
  vertex_id <- function(i, j) i * (m + 1) + j
  
  edges_list <- list()
  for (i in 0:n) {
    for (j in 1:m) {
      if (h[i + 1, j] == 1) {
        edges_list[[length(edges_list) + 1]] <- c(vertex_id(i, j - 1), vertex_id(i, j))
      }
    }
  }
  for (i in 1:n) {
    for (j in 0:m) {
      if (v[i, j + 1] == 1) {
        edges_list[[length(edges_list) + 1]] <- c(vertex_id(i - 1, j), vertex_id(i, j))
      }
    }
  }
  
  if (length(edges_list) == 0) return(0)
  
  all_vertices <- unique(unlist(edges_list))
  parent <- setNames(all_vertices, as.character(all_vertices))
  
  find_root <- function(x) {
    while (parent[[as.character(x)]] != x) {
      x <- parent[[as.character(x)]]
    }
    x
  }
  
  union_nodes <- function(a, b) {
    ra <- find_root(a)
    rb <- find_root(b)
    if (ra != rb) {
      parent[[as.character(ra)]] <<- rb
    }
  }
  
  for (e in edges_list) {
    union_nodes(e[1], e[2])
  }
  
  roots <- vapply(all_vertices, find_root, numeric(1))
  length(unique(roots))
}