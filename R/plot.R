#' Afficher un puzzle Slitherlink
#'
#' Dessine un puzzle Slitherlink avec `ggplot2` : les points de la grille,
#' les indices dans les cases, et les aretes actuellement tracees.
#'
#' @param x Un objet de classe `slitherlink`.
#' @param show_grid Logique. Si `TRUE`, affiche les aretes non tracees en
#'   gris clair pour visualiser la grille. Defaut : `TRUE`.
#' @param ... Arguments supplementaires (non utilises).
#'
#' @return Un objet `ggplot`.
#'
#' @examples
#' clues <- matrix(c(NA, 3, NA, 2,
#'                   2, NA, 1, NA,
#'                   NA, 0, NA, 3), nrow = 3, byrow = TRUE)
#' p <- new_puzzle(clues)
#' plot(p)
#'
#' @importFrom ggplot2 ggplot aes geom_segment geom_point geom_text
#'   coord_equal theme_void scale_y_reverse
#' @export
plot.slitherlink <- function(x, show_grid = TRUE, ...) {
  n <- x$n
  m <- x$m
  
  # Coordonnees des points de la grille
  # On utilise la convention : point (i, j) est a (x = j, y = i)
  # Les lignes augmentent vers le bas (d'ou scale_y_reverse plus tard).
  points_df <- expand.grid(
    row = 0:n,
    col = 0:m
  )
  
  # Aretes horizontales : relient (i, j) a (i, j+1)
  # h_edges[i+1, j+1] correspond a l'arete horizontale au-dessus de la case (i+1, j+1)
  h_list <- list()
  for (i in 0:n) {
    for (j in 1:m) {
      if (x$h_edges[i + 1, j] == 1) {
        h_list[[length(h_list) + 1]] <- data.frame(
          x = j - 1, y = i, xend = j, yend = i, traced = TRUE
        )
      } else if (show_grid) {
        h_list[[length(h_list) + 1]] <- data.frame(
          x = j - 1, y = i, xend = j, yend = i, traced = FALSE
        )
      }
    }
  }
  
  # Aretes verticales : relient (i, j) a (i+1, j)
  v_list <- list()
  for (i in 1:n) {
    for (j in 0:m) {
      if (x$v_edges[i, j + 1] == 1) {
        v_list[[length(v_list) + 1]] <- data.frame(
          x = j, y = i - 1, xend = j, yend = i, traced = TRUE
        )
      } else if (show_grid) {
        v_list[[length(v_list) + 1]] <- data.frame(
          x = j, y = i - 1, xend = j, yend = i, traced = FALSE
        )
      }
    }
  }
  
  edges_df <- do.call(rbind, c(h_list, v_list))
  
  # Indices dans les cases
  clues_df <- data.frame()
  for (i in 1:n) {
    for (j in 1:m) {
      if (!is.na(x$clues[i, j])) {
        clues_df <- rbind(clues_df, data.frame(
          col = j - 0.5,
          row = i - 0.5,
          label = as.character(x$clues[i, j])
        ))
      }
    }
  }
  
  # Construction du graphique
  g <- ggplot2::ggplot()
  
  # Aretes non tracees (grises, fines)
  if (show_grid && any(!edges_df$traced)) {
    g <- g + ggplot2::geom_segment(
      data = edges_df[!edges_df$traced, ],
      ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
      color = "grey80", linewidth = 0.3
    )
  }
  
  # Aretes tracees (noires, epaisses)
  if (any(edges_df$traced)) {
    g <- g + ggplot2::geom_segment(
      data = edges_df[edges_df$traced, ],
      ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
      color = "black", linewidth = 1.8
    )
  }
  
  # Points de la grille
  g <- g + ggplot2::geom_point(
    data = points_df,
    ggplot2::aes(x = col, y = row),
    size = 1.8, color = "black"
  )
  
  # Indices
  if (nrow(clues_df) > 0) {
    g <- g + ggplot2::geom_text(
      data = clues_df,
      ggplot2::aes(x = col, y = row, label = label),
      size = 6, fontface = "bold"
    )
  }
  
  g +
    ggplot2::coord_equal() +
    ggplot2::scale_y_reverse() +
    ggplot2::theme_void()
}