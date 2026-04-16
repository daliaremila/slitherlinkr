observeEvent(input$plot_click, {
  res <- 0.2  # Sensibilité du clic
  x <- input$plot_click$x
  y <- input$plot_click$y
  
  # Est-ce un clic sur une arête horizontale ?
  # (y proche d'un entier, x entre deux entiers)
  if (abs(y - round(y)) < res && abs(x - (floor(x) + 0.5)) < 0.5) {
    game$p <- toggle_edge(game$p, "h", round(y) + 1, floor(x) + 1)
  }
  
  # Est-ce un clic sur une arête verticale ?
  # (x proche d'un entier, y entre deux entiers)
  else if (abs(x - round(x)) < res && abs(y - (floor(y) + 0.5)) < 0.5) {
    game$p <- toggle_edge(game$p, "v", floor(y) + 1, round(x) + 1)
  }
})