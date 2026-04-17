library(shiny)

ui <- fluidPage(
  titlePanel("Slitherlink  - Dalia & Aly"),
  sidebarLayout(
    sidebarPanel(
      selectInput("level", "Difficulté :", 
                  choices = c("Débutant (3x3)" = "easy", "Pro (5x5)" = "medium", "Expert (7x7)" = "hard")),
      radioButtons("mode", "Outil", choices = c("Ligne (Noir)" = "line", "Croix (Rouge)" = "cross")),
      actionButton("check", "Vérifier la Solution"),
      hr(),
      verbatimTextOutput("status")
    ),
    mainPanel(plotOutput("game", click = "plot_click", height = "600px"))
  )
)

server <- function(input, output) {
  # Génération des niveaux
  observeEvent(input$level, {
    mat <- if(input$level == "easy") matrix(c(3,2,NA,NA,0,NA,3,NA,2),3,3)
    else if(input$level == "medium") matrix(sample(c(0,1,2,3,NA), 25, replace=T),5,5)
    else matrix(sample(c(0,1,2,3,NA), 49, replace=T),7,7)
    game$p <- new_puzzle(mat)
  })
  
  game <- reactiveValues(p = NULL)
  
  output$game <- renderPlot({ req(game$p); plot(game$p) })
  
  observeEvent(input$plot_click, {
    req(game$p)
    x <- input$plot_click$x; y <- input$plot_click$y
    # Algorithme de détection par distance euclidienne
    n <- game$p$n; m <- game$p$m; best_dist <- 0.4; best_edge <- NULL
    
    # Test horizontales
    for(i in 0:n) for(j in 1:m) {
      d <- sqrt((x-(j-0.5))^2 + (y-i)^2)
      if(d < best_dist) { best_dist <- d; best_edge <- list(t="h", r=i+1, c=j) }
    }
    # Test verticales
    for(i in 1:n) for(j in 0:m) {
      d <- sqrt((x-j)^2 + (y-(i-0.5))^2)
      if(d < best_dist) { best_dist <- d; best_edge <- list(t="v", r=i, c=j+1) }
    }
    
    if(!is.null(best_edge)) game$p <- toggle_edge(game$p, best_edge$t, best_edge$r, best_edge$c, input$mode)
  })
  
  observeEvent(input$check, {
    res <- is_solved(game$p) # Utilise ta fonction de solve.R
    output$status <- renderText(res$msg)
  })
}

shinyApp(ui, server)
