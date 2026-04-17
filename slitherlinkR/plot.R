#' @export
plot.slitherlink <- function(x) {
  library(ggplot2)
  n <- x$n; m <- x$m
  
  # 1. Génération de toutes les arêtes possibles (Gris par défaut)
  df_h <- expand.grid(y = 0:n, x_start = 0:(m-1))
  df_v <- expand.grid(x = 0:m, y_start = 0:(n-1))
  
  g <- ggplot() +
    # Arêtes horizontales grises (fond)
    geom_segment(data=df_h, aes(x=x_start, y=y, xend=x_start+1, yend=y), color="grey90") +
    # Arêtes verticales grises (fond)
    geom_segment(data=df_v, aes(x=x, y=y_start, xend=x, yend=y_start+1), color="grey90") +
    # Points de la grille
    geom_point(data=expand.grid(x=0:m, y=0:n), aes(x, y), size=2, color="grey30")
  
  # 2. Ajout des traits noirs (valeur 1)
  h_active <- which(x$h_edges == 1, arr.ind = TRUE)
  if(nrow(h_active) > 0) {
    df_ha <- data.frame(x=h_active[,2]-1, y=h_active[,1]-1, xend=h_active[,2], yend=h_active[,1]-1)
    g <- g + geom_segment(data=df_ha, aes(x=x, y=y, xend=xend, yend=yend), color="black", linewidth=1.5)
  }
  
  v_active <- which(x$v_edges == 1, arr.ind = TRUE)
  if(nrow(v_active) > 0) {
    df_va <- data.frame(x=v_active[,2]-1, y=v_active[,1]-1, xend=v_active[,2]-1, yend=v_active[,1])
    g <- g + geom_segment(data=df_va, aes(x=x, y=y, xend=xend, yend=yend), color="black", linewidth=1.5)
  }
  
  # 3. Croix rouges
  h_cross <- which(x$h_edges == -1, arr.ind = TRUE)
  if(nrow(h_cross) > 0) g <- g + geom_text(data=as.data.frame(h_cross), aes(x=col-0.5, y=row-1, label="x"), color="red")
  
  # 4. Chiffres (indices)
  clues_df <- expand.grid(y = 0.5:(n-0.5), x = 0.5:(m-0.5))
  clues_df$val <- as.vector(x$clues)
  clues_df <- clues_df[!is.na(clues_df$val),]
  g <- g + geom_text(data=clues_df, aes(x=x, y=y, label=val), size=6, fontface="bold") +
    scale_y_reverse() + coord_fixed() + theme_void()
  
  return(g)
}
