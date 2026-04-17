library(ggplot2)

plot_puzzle <- function(p) {
  if (is.null(p)) return(NULL)
  n <- p$n; m <- p$m
  
  df_chiffres <- as.data.frame(which(!is.na(p$clues), arr.ind = TRUE))
  if (nrow(df_chiffres) > 0) {
    df_chiffres$val <- p$clues[!is.na(p$clues)]
    df_chiffres$x <- df_chiffres$col - 0.5
    df_chiffres$y <- n - df_chiffres$row + 0.5
  }
  
  h_actifs <- which(p$h_edges == 1, arr.ind = TRUE)
  df_h <- if(nrow(h_actifs) > 0) data.frame(x = h_actifs[,2]-1, xend = h_actifs[,2], y = n-h_actifs[,1]+1, yend = n-h_actifs[,1]+1) else data.frame()
  
  v_actifs <- which(p$v_edges == 1, arr.ind = TRUE)
  df_v <- if(nrow(v_actifs) > 0) data.frame(x = v_actifs[,2]-1, xend = v_actifs[,2]-1, y = n-v_actifs[,1], yend = n-v_actifs[,1]+1) else data.frame()
  
  h_croix <- which(p$h_edges == -1, arr.ind = TRUE)
  df_cx_h <- if(nrow(h_croix) > 0) data.frame(x = h_croix[,2]-0.5, y = n-h_croix[,1]+1) else data.frame()
  
  v_croix <- which(p$v_edges == -1, arr.ind = TRUE)
  df_cx_v <- if(nrow(v_croix) > 0) data.frame(x = v_croix[,2]-1, y = n-v_croix[,1]+0.5) else data.frame()
  
  g <- ggplot() +
    geom_tile(data = expand.grid(x = 1:m - 0.5, y = 1:n - 0.5), aes(x, y), fill = "#fdfdfd", color = "#eeeeee")
  
  if (nrow(df_h) > 0) g <- g + geom_segment(data = df_h, aes(x=x, y=y, xend=xend, yend=yend), color = "#00d2ff", size = 2.5, lineend = "round")
  if (nrow(df_v) > 0) g <- g + geom_segment(data = df_v, aes(x=x, y=y, xend=xend, yend=yend), color = "#00d2ff", size = 2.5, lineend = "round")
  if (nrow(df_cx_h) > 0) g <- g + geom_text(data = df_cx_h, aes(x, y), label = "×", color = "#ff4b2b", size = 8, fontface = "bold")
  if (nrow(df_cx_v) > 0) g <- g + geom_text(data = df_cx_v, aes(x, y), label = "×", color = "#ff4b2b", size = 8, fontface = "bold")
  if (nrow(df_chiffres) > 0) g <- g + geom_text(data = df_chiffres, aes(x, y, label = val), size = 12, fontface = "bold", color = "#2c3e50")
  
  g + geom_point(data = expand.grid(x = 0:m, y = 0:n), aes(x, y), color = "#bdc3c7", size = 2) +
    theme_void() + theme(panel.background = element_rect(fill = "white", color = NA))
}
