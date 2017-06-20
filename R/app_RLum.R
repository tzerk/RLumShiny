#' Run Luminescence shiny apps
#' 
#' A wrapper for \code{\link{runApp}} to start interactive shiny apps for the R package Luminescence.
#' 
#' The RLumShiny package provides a single function from which all shiny apps can be started: \code{app_RLum()}. 
#' It essentially only takes one argument, which is a unique keyword specifying which application to start. 
#' See the table below for a list of available shiny apps and which keywords to use. If no keyword is used
#' a dashboard will be started instead, from which an application can be started.
#' 
#' \tabular{lcl}{
#' \bold{Application name:} \tab  \bold{Keyword:}  \tab \bold{Function:} \cr
#' Abanico Plot \tab \emph{abanico} \tab \code{\link{plot_AbanicoPlot}} \cr
#' Histogram \tab \emph{histogram} \tab \code{\link{plot_Histogram}} \cr
#' Kernel Density Estimate Plot \tab \emph{KDE} \tab \code{\link{plot_KDE}} \cr
#' Radial Plot \tab \emph{radialplot} \tab \code{\link{plot_RadialPlot}} \cr
#' Dose Recovery Test \tab \emph{doserecovery} \tab \code{\link{plot_DRTResults}} \cr
#' Cosmic Dose Rate \tab \emph{cosmicdose}  \tab \code{\link{calc_CosmicDoseRate}} \cr
#' CW Curve Transformation \tab \emph{transformCW} \tab \code{\link{CW2pHMi}, \link{CW2pLM}, \link{CW2pLMi}, \link{CW2pPMi}} \cr
#' Filter Combinations \tab \emph{filter} \tab \code{\link{plot_FilterCombinations}}
#' }
#' 
#' The \code{app_RLum()} function is just a wrapper for \code{\link{runApp}}. 
#' Via the \code{...} argument further arguments can be directly passed to \code{\link{runApp}}. 
#' See \code{?shiny::runApp} for further details on valid arguments.
#' 
#' @param app \code{\link{character}} (required): name of the application to start. See details for a list
#' of available apps.
#' @param ... further arguments to pass to \code{\link{runApp}}
#' @author Christoph Burow, University of Cologne (Germany)
#' @seealso \code{\link{runApp}}
#' @examples 
#' 
#' \dontrun{
#' # Dashboard
#' app_RLum()
#' 
#' # Plotting apps
#' app_RLum("abanico")
#' app_RLum("histogram")
#' app_RLum("KDE")
#' app_RLum("radialplot")
#' app_RLum("doserecovery")
#' 
#' # Further apps
#' app_RLum("cosmicdose")
#' app_RLum("transformCW")
#' app_RLum("filter")
#' }
#' 
#' @export app_RLum
app_RLum <- function(app = NULL, ...) {
  
  valid_apps <- c("abanico",
                  "cosmicdose",
                  "doserecovery",
                  "histogram",
                  "KDE",
                  "radialplot",
                  "transformCW",
                  "filter")
  
  if (is.null(app)) {
    
    # start the RLumShiny Dashboard Addin
    RLumShinyAddin()
    
  } else {
    
    # check if keyword is valid
    if (!any(grepl(app, valid_apps, ignore.case = TRUE))) 
      return(message(paste0("Invalid app name: ", app, " \n Valid options are: ", paste(valid_apps, collapse = ", "))))
    
    # start application
    app <- shiny::runApp(system.file(paste0("shiny/", app), package = "RLumShiny"), launch.browser = TRUE,  ...)
  }
  
}