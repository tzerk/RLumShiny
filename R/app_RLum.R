#' Run Luminescence shiny apps
#' 
#' A wrapper for \code{\link{runApp}} to start interactive shiny apps for the R package Luminescence.
#' 
#' \tabular{lcl}{
#' \bold{Application name:} \tab    \tab \bold{Function:} \cr
#' abanico \tab -> \tab \code{\link{plot_AbanicoPlot}} \cr
#' histogram \tab -> \tab \code{\link{plot_Histogram}} \cr
#' KDE \tab -> \tab \code{\link{plot_KDE}} \cr
#' radialplot \tab -> \tab \code{\link{plot_RadialPlot}} \cr
#' doserecovery \tab -> \tab \code{\link{plot_DRTResults}} \cr
#' cosmicdose \tab ->  \tab \code{\link{calc_CosmicDoseRate}}
#' }
#' 
#' @param app \code{\link{character}} (required): name of the RLum app to start. See details for a list
#' of available apps.
#' @param ... further arguments to pass to \code{\link{runApp}}
#' @author Christoph Burow, University of Cologne (Germany)
#' @seealso \code{\link{runApp}}
#' @examples 
#' 
#' \dontrun{
#' # Plotting apps
#' app_RLum("abanico")
#' app_RLum("histogram")
#' app_RLum("KDE")
#' app_RLum("radialplot")
#' app_RLum("doserecovery")
#' 
#' # Further apps
#' app_RLum("cosmicdose")
#' }
#' 
#' @export app_RLum
app_RLum <- function(app, ...) {
  
  valid_apps <- c("abanico",
                  "cosmicdose",
                  "doserecovery",
                  "histogram",
                  "KDE",
                  "radialplot")
  
  if (!app %in% valid_apps) 
    return(message(paste0("Invalid app name: ", app, " \n Valid options are: ", paste(valid_apps, collapse = ", "))))
  
  app <- shiny::runApp(system.file(paste0("shiny/", app), package = "RLumShiny"), ...)
  
}