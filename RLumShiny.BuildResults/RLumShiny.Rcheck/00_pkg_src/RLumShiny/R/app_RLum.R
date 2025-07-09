#' @title Run Luminescence shiny apps
#'
#' @description A wrapper for [shiny::runApp] to start interactive shiny apps for the R package Luminescence.
#'
#' The RLumShiny package provides a single function from which all shiny apps can be started: `app_RLum()`.
#' It essentially only takes one argument, which is a unique keyword specifying which application to start.
#' See the table below for a list of available shiny apps and which keywords to use. If no keyword is used
#' a dashboard will be started instead, from which an application can be started.
#'
#' \tabular{lcl}{
#' **Application name:** \tab  **Keyword:**  \tab **Function:** \cr
#' Abanico Plot \tab *abanico* \tab [Luminescence::plot_AbanicoPlot] \cr
#' Histogram \tab *histogram* \tab [Luminescence::plot_Histogram] \cr
#' Kernel Density Estimate Plot \tab *KDE* \tab [Luminescence::plot_KDE] \cr
#' Radial Plot \tab *radialplot* \tab [Luminescence::plot_RadialPlot] \cr
#' Aliquot Size \tab *aliquotsize* \tab [Luminescence::calc_AliquotSize] \cr
#' Dose Recovery Test \tab *doserecovery* \tab [Luminescence::plot_DRTResults] \cr
#' Cosmic Dose Rate \tab *cosmicdose*  \tab [Luminescence::calc_CosmicDoseRate] \cr
#' CW Curve Transformation \tab *transformCW* \tab [Luminescence::convert_CW2pHMi], [Luminescence::convert_CW2pLM], [Luminescence::convert_CW2pLMi], [Luminescence::convert_CW2pPMi] \cr
#' Filter Combinations \tab *filter* \tab [Luminescence::plot_FilterCombinations] \cr
#' Fast Ratio \tab *fastratio* \tab [Luminescence::calc_FastRatio] \cr
#' Fading Correction \tab *fading* \tab [Luminescence::analyse_FadingMeasurement], [Luminescence::calc_FadingCorr] \cr
#' Finite Mixture \tab *finitemixture* \tab [Luminescence::calc_FiniteMixture] \cr
#' Huntley (2006) \tab *huntley2006* \tab [Luminescence::calc_Huntley2006] \cr
#' IRSAR RF \tab *irsarRF* \tab [Luminescence::analyse_IRSAR.RF] \cr
#' LM Curve \tab *lmcurve* \tab [Luminescence::fit_LMCurve] \cr
#' Test Stimulation Power \tab *teststimulationpower* \tab  [Luminescence::plot_RLum] \cr
#' Scale Gamma Dose Rate \tab *scalegamma* \tab [Luminescence::scale_GammaDose] \cr
#' RCarb app \tab *RCarb* \tab [RCarb::model_DoseRate]
#' }
#'
#' The `app_RLum()` function is just a wrapper for [shiny::runApp].
#' Via the `...` argument further arguments can be directly passed to [shiny::runApp].
#' See `?shiny::runApp` for further details on valid arguments.
#'
#'
#' @param app [character] (**required**):
#' name of the application to start. See details for a list of available apps.
#'
#' @param ... further arguments to pass to [shiny::runApp]
#'
#' @author Christoph Burow, University of Cologne (Germany)
#'
#' @seealso [shiny::runApp]
#'
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
#' app_RLum("aliquotsize")
#' app_RLum("cosmicdose")
#' app_RLum("transformCW")
#' app_RLum("filter")
#' app_RLum("fastratio")
#' app_RLum("fading")
#' app_RLum("finitemixture")
#' app_RLum("huntley2006")
#' app_RLum("irsarRF")
#' app_RLum("lmcurve")
#' app_RLum("surfaceexposure")
#' app_RLum("teststimulationpower")
#' app_RLum("scalegamma")
#' app_RLum("RCarb")
#' }
#'
#' @md
#' @export app_RLum
app_RLum <- function(app = NULL, ...) {

  valid_apps <- c("abanico",
                  "aliquotsize",
                  "cosmicdose",
                  "doserecovery",
                  "histogram",
                  "KDE",
                  "radialplot",
                  "transformCW",
                  "filter",
                  "fastratio",
                  "fading",
                  "finitemixture",
                  "huntley2006",
                  "irsarRF",
                  "lmcurve",
                  "surfaceexposure",
                  "teststimulationpower",
                  "scalegamma",
                  "RCarb"
                  )

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
