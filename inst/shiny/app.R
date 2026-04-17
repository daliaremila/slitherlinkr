library(shiny)
library(ggplot2)
# source("R/puzzle.R")
# source("R/solve.R")
# source("R/plot.R")
# source("R/puzzles.R")

# --- Code de l'Interface Utilisateur (UI) ---
ui <- fluidPage(
  titlePanel("Slitherlink Expert"),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("level", "Choisir un niveau :",
                  choices = c("Facile" = "easy", "Moyen" = "medium", "Difficile" = "hard")),
      radioButtons("mode", "Action du clic :",
                   choices = c("Ligne" = "line", "Croix (X)" = "cross")),
      actionButton("reset", "Réinitialiser", width = "100%"),
      hr(),
      actionButton("check", "Vérifier ma solution", width = "100%"),
      hr(),
      verbatimTextOutput("status")
    ),
    mainPanel(
      width = 9,
      plotOutput("game_plot", click = "plot_click", height = "600px", width = "600px")
    )
  )
)

# --- Code du Serveur ---
server <- function(input, output, session) {
  
  # 1. Stockage du puzzle dans une valeur réactive
  game <- reactiveValues(p = NULL)
  
  # 2. Initialisation du niveau
  observeEvent(input$level, {
    # On suppose que puzzle_easy/medium/hard sont chargés via puzzles.R
    puz <- switch(input$level,
                  "easy"   = puzzle_easy,
                  "medium" = puzzle_medium,
                  "hard"   = puzzle_hard)
    game$p <- new_puzzle(puz$clues)
  }, ignoreNULL = FALSE)
  
  # 3. Réinitialisation
  observeEvent(input$reset, {
    req(game$p)
    game$p <- new_puzzle(game$p$clues)
  })
  
  # 4. Rendu du graphique
  output$game_plot <- renderPlot({
    req(game$p)
    plot(game$p) 
  })
  
  # 5. Gestion du clic (Calcul de proximité)
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
    
    # Chercher l'arête horizontale
    for (i in 0:n) {
      for (j in 1:m) {
        cx <- j - 0.5
        cy <- i 
        d <- sqrt((x - cx)^2 + (y - cy)^2)
        if (d < best_dist && d < seuil) {
          best_dist <- d
          best_type <- "h"
          best_r <- i + 1
          best_c <- j
        }
      }
    }
    
    # Chercher l'arête verticale
    for (i in 1:n) {
      for (j in 0:m) {
        cx <- j
        cy <- i - 0.5
        d <- sqrt((x - cx)^2 + (y - cy)^2)
        if (d < best_dist && d < seuil) {
          best_dist <- d
          best_type <- "v"
          best_r <- i
          best_c <- j + 1
        }
      }
    }
    
    # SÉCURITÉ : On modifie uniquement si une arête est touchée
    if (!is.null(best_type)) {
      game$p <- toggle_edge(game$p, best_type, best_r, best_c, mode = input$mode)
    }
  })
  
  # 6. Vérification de la victoire
  observeEvent(input$check, {
    req(game$p)
    res <- is_solved(game$p)
    
    if (res$solved) {
      output$status <- renderText("BRAVO ! Puzzle résolu !")
    } else {
      # Construction du message d'erreur
      msg <- "Échec :\n"
      if (!res$clues_ok)   msg <- paste0(msg, "- Indices incorrects\n")
      if (!res$vertices_ok) msg <- paste0(msg, "- Sommets incorrects (entree/sortie)\n")
      if (res$n_loops == 0) msg <- paste0(msg, "- Aucune ligne tracee\n")
      if (res$n_loops > 1)  msg <- paste0(msg, "- Trop de boucles (formez un seul circuit)\n")
      
      output$status <- renderText(msg)
    }
  })
}

# Lancement de l'app
shinyApp(ui, server)