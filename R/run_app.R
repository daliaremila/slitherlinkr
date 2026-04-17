#' Lancer l'application Shiny Slitherlink
#'
#' Ouvre l'application Shiny interactive pour jouer au Slitherlink
#' dans le navigateur web.
#'
#' @export
run_app <- function() {
  app_dir <- system.file("shiny", package = "slitherlinkr")
  if (app_dir == "") {
    stop("Application Shiny introuvable. Reinstallez le package.")
  }
  shiny::runApp(app_dir, display.mode = "normal")
}