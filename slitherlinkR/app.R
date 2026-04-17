library(shiny)
library(shinythemes)
library(ggplot2)

if (interactive()) {
  setwd(dirname(rstudioapi::getSourceEditorContext()$path))
}

source("puzzle.R", local = TRUE)
source("plot.R", local = TRUE)
source("solve.R", local = TRUE)

ui <- fluidPage(
  theme = shinytheme("flatly"),
  tags$head(
    tags$style(HTML("
      body { background-color: #f4f7f6; }
      .main-header { background: linear-gradient(135deg, #2c3e50, #34495e); color: white; padding: 30px; border-radius: 0 0 20px 20px; margin-bottom: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.3); }
      .control-panel { background: white; border-radius: 15px; padding: 20px; box-shadow: 0 8px 20px rgba(0,0,0,0.05); margin-bottom: 20px; }
      .btn-verify { background: #27ae60 !important; color: white !important; font-weight: 800 !important; font-size: 1.2em !important; border: none !important; padding: 15px !important; margin-top: 10px; }
      .stat-box { background: white; padding: 15px; border-radius: 10px; text-align: center; border-bottom: 4px solid #bdc3c7; min-height: 80px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
      .stat-value { font-size: 1.3em; font-weight: bold; color: #2c3e50; display: block; margin-top: 5px; }
      .stat-label { font-size: 0.8em; text-transform: uppercase; color: #7f8c8d; font-weight: bold; }
      #grid_plot { background-color: white; border-radius: 10px; cursor: crosshair; }
    "))
  ),
  
  div(class = "text-center main-header",
      h1(icon("draw-polygon"), "Slitherlink & Shiny"),
      p("Slitherlink : Logic & Topology")
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 4,
      # 1. BLOC DE CONFIGURATION
      div(class = "control-panel",
          h4(icon("sliders-h"), "Configuration"),
          hr(),
          selectInput("level", "Difficulté :", 
                      choices = list("🟢 Débutant (3x3)" = "easy", "🟡 Moyen (5x5)" = "medium", "🔴 Expert (7x7)" = "hard"),
                      selected = "medium"),
          radioButtons("mode", "Action :",
                       choiceNames = list(tagList(icon("pen-nib", style="color:#3498db"), "Tracer"), tagList(icon("times-circle", style="color:#e74c3c"), "Exclure")),
                       choiceValues = list("line", "cross"), inline = TRUE),
          hr(),
          actionButton("verify", "VÉRIFIER LA BOUCLE", class = "btn-block btn-verify", icon = icon("check-double")),
          actionButton("reset", "Nouvelle Grille", class = "btn-block btn-warning", icon = icon("sync"), style="margin-top:10px;")
      ),
      
      # 2. BLOC DES RÈGLES
      div(style = "background:#e8f4f8; padding:15px; border-radius:10px; border-left: 5px solid #3498db;",
          h5(icon("bullseye"), "Objectif du Jeu", style="color:#2c3e50; font-weight:bold;"),
          p("Formez une boucle fermée unique respectant les chiffres.", style="font-size:0.9em;"),
          hr(style="border-top: 1px solid #bdc3c7; margin: 10px 0;"),
          h5(icon("check-square"), "Contraintes", style="color:#2c3e50; font-weight:bold;"),
          tags$ul(style = "padding-left: 15px; font-size: 0.85em; color: #34495e;",
                  tags$li("Chiffre = nombre de segments autour."),
                  tags$li("Pas de croisement ni de branchement."),
                  tags$li("Sommets : 0 ou 2 segments connectés.")
          ),
          hr(style="border-top: 1px solid #bdc3c7; margin: 10px 0;"),
          h5(icon("mouse-pointer"), "Contrôles", style="color:#2c3e50; font-weight:bold;"),
          tags$p(style="font-size: 0.85em; margin-bottom:0;",
                 icon("mouse"), " Cliquez entre deux points.", br(),
                 icon("sync-alt"), " Changez de mode pour les croix."
          )
      )
    ),
    
    mainPanel(
      width = 8,
      wellPanel(plotOutput("grid_plot", click = "grid_click", height = "550px")),
      uiOutput("game_message"),
      br(),
      fluidRow(
        column(4, div(class="stat-box", span(class="stat-label", icon("clock"), "Temps"), span(class="stat-value", textOutput("timer", inline=TRUE)))),
        column(4, div(class="stat-box", span(class="stat-label", icon("tasks"), "Segments"), span(class="stat-value", textOutput("seg_count", inline=TRUE)))),
        column(4, uiOutput("status_ui"))
      )
    )
  )
)

server <- function(input, output, session) {
  game <- reactiveValues(p = NULL, start_time = NULL)
  
  observeEvent(list(input$level, input$reset), {
    probs <- if(input$level == "easy") c(0.1, 0.2, 0.2, 0.1, 0.4) else if(input$level == "medium") c(0.15, 0.15, 0.15, 0.25, 0.3) else c(0.2, 0.1, 0.1, 0.4, 0.2)
    size <- switch(input$level, "easy" = 3, "medium" = 5, "hard" = 7)
    mat <- matrix(sample(c(0,1,2,3,NA), size^2, replace = TRUE, prob = probs), size, size)
    game$p <- new_puzzle(mat)
    game$start_time <- Sys.time()
    output$game_message <- renderUI(NULL) 
  })
  
  output$timer <- renderText({
    invalidateLater(1000, session)
    req(game$start_time)
    diff <- round(as.numeric(difftime(Sys.time(), game$start_time, units="secs")))
    sprintf("%02d:%02d", diff %/% 60, diff %% 60)
  })
  
  output$seg_count <- renderText({
    req(game$p)
    sum(game$p$h_edges == 1) + sum(game$p$v_edges == 1)
  })
  
  output$status_ui <- renderUI({
    req(game$p)
    count <- sum(game$p$h_edges == 1) + sum(game$p$v_edges == 1)
    limit <- if(game$p$n == 3) 8 else if(game$p$n == 5) 15 else 25
    
    status_text <- "Au travail !"
    status_color <- "#bdc3c7"
    if(count > 0) { status_text <- "En cours..."; status_color <- "#3498db" }
    if(count >= limit) { status_text <- "On y est presque !"; status_color <- "#f39c12" }
    
    div(class="stat-box", style=paste0("border-bottom-color:", status_color),
        span(class="stat-label", icon("info-circle"), "État"),
        span(class="stat-value", style=paste0("color:", status_color), status_text)
    )
  })
  
  output$grid_plot <- renderPlot({
    req(game$p)
    plot_puzzle(game$p) 
  })
  
  observeEvent(input$grid_click, {
    req(game$p)
    x <- input$grid_click$x; y <- input$grid_click$y
    n <- game$p$n; m <- game$p$m
    best_dist <- 0.4; best_edge <- NULL
    for(i in 0:n) for(j in 1:m) {
      d <- sqrt((x - (j - 0.5))^2 + (y - (n - i))^2)
      if(d < best_dist) { best_dist <- d; best_edge <- list(t="h", r=i+1, c=j) }
    }
    for(i in 1:n) for(j in 0:m) {
      d <- sqrt((x - j)^2 + (y - (n - i + 0.5))^2)
      if(d < best_dist) { best_dist <- d; best_edge <- list(t="v", r=i, c=j+1) }
    }
    if(!is.null(best_edge)) game$p <- toggle_edge(game$p, best_edge$t, best_edge$r, best_edge$c, input$mode)
  })
  
  observeEvent(input$verify, {
    req(game$p)
    res <- is_solved(game$p) 
    output$game_message <- renderUI({
      div(class = if(res$solved) "alert alert-success" else "alert alert-warning",
          style = "text-align:center; font-size:1.2em;", icon(if(res$solved) "trophy" else "exclamation-circle"), res$msg)
    })
  })
}

shinyApp(ui, server)
