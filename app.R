library(shiny)
library(slitherlinkr)

# 1. L'interface (la carrosserie)
ui <- fluidPage(
  titlePanel("Slitherlink - Projet Binôme"),
  sidebarLayout(
    sidebarPanel(
      selectInput("level", "Niveau :", choices = c("easy", "medium", "hard")),
      actionButton("check", "Vérifier"),
      textOutput("status")
    ),
    mainPanel(
      plotOutput("game_plot", click = "plot_click")
    )
  )
)

# 2. Le serveur (le moteur)
server <- function(input, output, session) {
  # Initialisation réactive du puzzle
  game <- reactiveValues(p = puzzle_easy)
  
  # Affichage
  output$game_plot <- renderPlot({
    plot(game$p)
  })
  
  # TON CODE DE CLIC ICI
  observeEvent(input$plot_click, {
    res <- 0.2
    x <- input$plot_click$x
    y <- input$plot_click$y
    
    if (abs(y - round(y)) < res && abs(x - (floor(x) + 0.5)) < 0.5) {
      game$p <- toggle_edge(game$p, "h", round(y) + 1, floor(x) + 1)
    }
    else if (abs(x - round(x)) < res && abs(y - (floor(y) + 0.5)) < 0.5) {
      game$p <- toggle_edge(game$p, "v", floor(y) + 1, round(x) + 1)
    }
  })
  
  # Vérification
  observeEvent(input$check, {
    res <- is_solved(game$p)
    output$status <- renderText({
      if(res$solved) "Gagné !" else "Encore un effort..."
    })
  })
}

# 3. Lancement
shinyApp(ui, server)