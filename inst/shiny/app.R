library(shiny)
library(slitherlinkr)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Slitherlink"),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("level", "Choisir un niveau :",
                  choices = c("Facile" = "easy",
                              "Moyen" = "medium",
                              "Difficile" = "hard")),
      actionButton("reset", "Reinitialiser", width = "100%"),
      hr(),
      actionButton("check", "Verifier ma solution", width = "100%"),
      hr(),
      verbatimTextOutput("status"),
      hr(),
      verbatimTextOutput("debug")
    ),
    mainPanel(
      width = 9,
      plotOutput("game_plot", click = "plot_click", height = "600px",
                 width = "600px")
    )
  )
)

server <- function(input, output, session) {
  
  game <- reactiveValues(p = NULL)
  
  observeEvent(input$level, {
    puz <- switch(input$level,
                  "easy"   = puzzle_easy,
                  "medium" = puzzle_medium,
                  "hard"   = puzzle_hard)
    game$p <- new_puzzle(puz$clues)
  }, ignoreNULL = FALSE)
  
  observeEvent(input$reset, {
    game$p <- new_puzzle(game$p$clues)
  })
  
  # Dessiner la grille directement (sans plot.slitherlink)
  output$game_plot <- renderPlot({
    req(game$p)
    p <- game$p
    n <- p$n
    m <- p$m
    
    # Points de la grille
    points_df <- expand.grid(row = 0:n, col = 0:m)
    
    # Aretes
    edges <- data.frame(x = numeric(), y = numeric(),
                        xend = numeric(), yend = numeric(),
                        traced = logical())
    
    for (i in 0:n) {
      for (j in 1:m) {
        edges <- rbind(edges, data.frame(
          x = j - 1, y = n - i, xend = j, yend = n - i,
          traced = (p$h_edges[i + 1, j] == 1)
        ))
      }
    }
    
    for (i in 1:n) {
      for (j in 0:m) {
        edges <- rbind(edges, data.frame(
          x = j, y = n - (i - 1), xend = j, yend = n - i,
          traced = (p$v_edges[i, j + 1] == 1)
        ))
      }
    }
    
    # Indices
    clues_df <- data.frame(col = numeric(), row = numeric(),
                           label = character())
    for (i in 1:n) {
      for (j in 1:m) {
        if (!is.na(p$clues[i, j])) {
          clues_df <- rbind(clues_df, data.frame(
            col = j - 0.5,
            row = n - i + 0.5,
            label = as.character(p$clues[i, j])
          ))
        }
      }
    }
    
    # Construire le ggplot
    g <- ggplot()
    
    # Aretes non tracees
    if (any(!edges$traced)) {
      g <- g + geom_segment(
        data = edges[!edges$traced, ],
        aes(x = x, y = y, xend = xend, yend = yend),
        color = "grey80", linewidth = 0.3
      )
    }
    
    # Aretes tracees
    if (any(edges$traced)) {
      g <- g + geom_segment(
        data = edges[edges$traced, ],
        aes(x = x, y = y, xend = xend, yend = yend),
        color = "black", linewidth = 2
      )
    }
    
    # Points
    g <- g + geom_point(
      data = data.frame(x = points_df$col, y = n - points_df$row),
      aes(x = x, y = y),
      size = 2.5, color = "black"
    )
    
    # Indices
    if (nrow(clues_df) > 0) {
      g <- g + geom_text(
        data = clues_df,
        aes(x = col, y = row, label = label),
        size = 8, fontface = "bold"
      )
    }
    
    g +
      coord_cartesian(xlim = c(-0.3, m + 0.3), ylim = c(-0.3, n + 0.3)) +
      theme_void()
  })
  
  # Gestion du clic
  observeEvent(input$plot_click, {
    req(game$p)
    
    x <- input$plot_click$x
    y <- input$plot_click$y
    
    if (is.null(x) || is.null(y)) return()
    
    n <- game$p$n
    m <- game$p$m
    seuil <- 0.4
    
    best_dist <- Inf
    best_type <- NULL
    best_r <- NULL
    best_c <- NULL
    
    # Aretes horizontales
    # Dans notre systeme : arete h[i+1, j] est dessinee a y = n - i, x entre j-1 et j
    # Centre : (j - 0.5, n - i)
    for (i in 0:n) {
      for (j in 1:m) {
        cx <- j - 0.5
        cy <- n - i
        d <- sqrt((x - cx)^2 + (y - cy)^2)
        if (d < best_dist && d < seuil) {
          best_dist <- d
          best_type <- "h"
          best_r <- i + 1
          best_c <- j
        }
      }
    }
    
    # Aretes verticales
    # arete v[i, j+1] est dessinee de y = n-(i-1) a y = n-i, x = j
    # Centre : (j, n - i + 0.5)
    for (i in 1:n) {
      for (j in 0:m) {
        cx <- j
        cy <- n - i + 0.5
        d <- sqrt((x - cx)^2 + (y - cy)^2)
        if (d < best_dist && d < seuil) {
          best_dist <- d
          best_type <- "v"
          best_r <- i
          best_c <- j + 1
        }
      }
    }
    
    output$debug <- renderText({
      paste0("x=", round(x, 2), " y=", round(y, 2),
             " type=", ifelse(is.null(best_type), "AUCUN", best_type),
             " r=", best_r, " c=", best_c,
             " dist=", round(best_dist, 3))
    })
    
    if (!is.null(best_type)) {
      game$p <- toggle_edge(game$p, best_type, best_r, best_c)
    }
  })
  
  observeEvent(input$check, {
    req(game$p)
    res <- is_solved(game$p)
    if (res$solved) {
      msg <- "BRAVO ! Puzzle resolu !"
    } else {
      problemes <- c()
      if (!res$clues_ok) problemes <- c(problemes, "Indices non respectes.")
      if (!res$vertices_ok) problemes <- c(problemes, "Points incorrects.")
      if (!res$single_loop) {
        if (res$n_loops == 0) {
          problemes <- c(problemes, "Aucune arete tracee.")
        } else {
          problemes <- c(problemes, paste0(res$n_loops, " boucle(s) au lieu d'une seule."))
        }
      }
      msg <- paste("Pas encore...\n", paste(problemes, collapse = "\n"))
    }
    output$status <- renderText(msg)
  })
}

shinyApp(ui, server)