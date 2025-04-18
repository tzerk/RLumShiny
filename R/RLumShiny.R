#' Shiny Applications for the R Package Luminescence
#'
#' A collection of shiny applications for the R package Luminescence.
#' These mainly, but not exclusively, include applications for plotting chronometric
#' data from e.g. luminescence or radiocarbon dating. It further provides access to
#' bootstraps tooltip and popover functionality as well as a binding to JSColor.
#'
#' In addition to its main purpose of providing convenient access to the Luminescence
#' shiny applications (see [`app_RLum`]) this package also provides further functions to extend the
#' functionality of shiny. From the Bootstrap framework the JavaScript tooltip and popover
#' components can be added to any shiny application via [`tooltip`] and [`popover`].
#' It further provides a custom input binding to the JavaScript/HTML color picker JSColor.
#' Offering access to most options provided by the JSColor API the function [`jscolorInput`]
#' is easily implemented in a shiny app. RGB colors are returned as hex values and can be
#' directly used in R's base plotting functions without the need of any format conversion.
#'
#' @name RLumShiny-package
#' @import Luminescence shiny googleVis shinydashboard rhandsontable data.table readxl leaflet
#' @importFrom RCarb model_DoseRate write_InputTemplate
#' @importFrom markdown markdownToHTML
#' @importFrom utils citation
#' @importFrom grDevices dev.off pdf postscript svg
#'
#' @md
"_PACKAGE"
