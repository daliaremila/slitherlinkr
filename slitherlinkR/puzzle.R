#' @export
new_puzzle <- function(clues) {
  n <- nrow(clues); m <- ncol(clues)
  puzzle <- list(
    clues = clues,
    h_edges = matrix(0L, nrow = n + 1, ncol = m), # 0:vide, 1:noir, -1:croix
    v_edges = matrix(0L, nrow = n, ncol = m + 1),
    n = n, m = m
  )
  class(puzzle) <- "slitherlink"
  return(puzzle)
}

#' @export
toggle_edge <- function(p, type, r, c, mode = "line") {
  if (type == "h") {
    curr <- p$h_edges[r, c]
    p$h_edges[r, c] <- if(mode == "line") ifelse(curr == 1, 0, 1) else ifelse(curr == -1, 0, -1)
  } else {
    curr <- p$v_edges[r, c]
    p$v_edges[r, c] <- if(mode == "line") ifelse(curr == 1, 0, 1) else ifelse(curr == -1, 0, -1)
  }
  return(p)
}