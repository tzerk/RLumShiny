function(request) {
  ## helper functions
  densityInput <- function(id, value) {
    numericInput(inputId = id, label = p(class = "h", "Density (g/cm\uB3)"),
                 value = value, min = 0, step = 0.1)
  }
  depthInput <- function(id, value) {
    numericInput(inputId = id, label = p(class = "h", "Depth (m)"),
                 value = value, min = 0, step = 0.01)
  }

  fluidPage(
    titlePanel(NULL, windowTitle = "RLumShiny - CosmicDose"),
    includeCSS("./www/style.css"),
    fluidRow(
      column(width = 3,
             div(align = "center", span(class="label label-info", "Site")),
             wellPanel(
               div(align = "left",
                   numericInput(inputId = "altitude", label = p(class="h","Altitude (m asl)"), value = 124, step = 1),
                   title = "Altitude (m above sea-level)."),
               selectInput(inputId = "coords", label = "Coordinates", selected = "decDeg",
                           choices = c("Decimal degrees" = "decDeg",
                                       "Degrees decimal minutes" = "degDecMin",
                                       "Degrees minutes seconds" = "degMinSec")),

               conditionalPanel(condition = "input.coords == 'decDeg'",
                                numericInput(inputId = "decDegN", label = p(class="h","North"), value = 50.926903, step = 0.000001),
                                numericInput(inputId = "decDegE", label = p(class="h","East"), value = 6.937453, step = 0.000001)
               ),
               conditionalPanel(condition = "input.coords == 'degDecMin'",
                                fluidRow(
                                  column(width = 4,
                                         numericInput(inputId = "degN_1", label = p(class="h","N: \uB0"), value = 50, step = 1),
                                         numericInput(inputId = "degE_1", label = p(class="h","E: \uB0"), value = 6, step = 1)
                                  ),
                                  column(width = 4, offset = 2,
                                         numericInput(inputId = "decMinN", label = p(class="h","Decimal \u27"), value = 55.61417, step = 0.000001),
                                         numericInput(inputId = "decMinE", label = p(class="h","Decimal \u27"), value = 56.24717, step = 0.000001)
                                  )
                                )
               ),
               conditionalPanel(condition = "input.coords == 'degMinSec'",
                                fluidRow(
                                  column(width = 3, offset = 0,
                                         numericInput(inputId = "degN_2", label = p(class="h","N: \uB0"), value = 50, step = 1),
                                         numericInput(inputId = "degE_2", label = p(class="h","E: \uB0"), value = 6, step = 1)
                                  ),
                                  column(width = 3,  offset = 1,
                                         numericInput(inputId = "minN", label = p(class="h","\u27"), value = 55, step = 1),
                                         numericInput(inputId = "minE", label = p(class="h","\u27"), value = 56, step = 1)
                                  ),
                                  column(width = 3, offset = 1,
                                         numericInput(inputId = "secN", label = p(class="h","\u27\u27"), value = 36.85, step = 0.01),
                                         numericInput(inputId = "secE", label = p(class="h","\u27\u27"), value = 14.83, step = 0.01)
                                  )
                                )
               )
             )
      ),
      column(width = 3,
             div(align = "center", span(class="label label-info", "Sediment")),

             wellPanel(
               div(align = "left",
                   densityInput("density_1", value = 2.0),
                   title = "Average overburden density (g/cm\uB3)."),

               conditionalPanel(condition = "input.mode == 'xAsS'",
                                densityInput("density_2", value = NULL),
                                densityInput("density_3", value = NULL),
                                densityInput("density_4", value = NULL),
                                densityInput("density_5", value = NULL)
               )
             )
      ),
      column(width = 3,
             div(align = "center", span(class="label label-info", "Samples")),

             wellPanel(
               div(align = "left",
                   depthInput("depth_1", value = 1.00),
                   title = "Depth of overburden (m)."),

               conditionalPanel(condition = "input.mode == 'sAxS' || input.mode == 'xAsS'",
                                depthInput("depth_2", value = NULL),
                                depthInput("depth_3", value = NULL),
                                depthInput("depth_4", value = NULL),
                                depthInput("depth_5", value = NULL)
               )
             )
      ),
      column(width = 3,
             div(align = "center", span(class="label label-info", "Options")),

             wellPanel(
               div(align = "left",
                   checkboxInput(inputId = "corr", label = p(class = "h", "Correct for geomagnetic field changes"), value = FALSE),
                   title = "Correct for geomagnetic field changes after Prescott & Hutton (1994). Apply only when justified by the data."),
               div(align = "left",
                   numericInput(inputId = "estage", label = p(class = "h", "Estimated age"), value = 30, step = 1, min = 0, max = 80),
                   title = "Estimated age range (ka) for geomagnetic field change correction (0-80 ka allowed)."),
               div(align = "left",
                   checkboxInput(inputId = "half", label = p(class = "h", "Use half the depth"), value = FALSE),
                   title= " How to overcome with varying overburden thickness. If TRUE only half the depth is used for calculation. Apply only when justified, i.e. when a constant sedimentation rate can safely be assumed."),
               div(align = "left",
                   numericInput(inputId = "error", label = p(class="h","General error (%)"), value = 10, step = 1),
                   title = "General error (percentage) to be implemented on corrected cosmic dose rate estimate."),
               selectInput(inputId = "mode", label = "Mode", selected = "sAsS",
                           choices = c("1 absorber, 1 sample" = "sAsS",
                                       "x absorber, 1 sample" = "xAsS",
                                       "1 absorber, x samples" = "sAxS"))
             ),

             actionButton(inputId = "refresh", label = "",
                          icon = icon("fas fa-sync"), title = "Reload app"),
             bookmarkButton()

      )
    ),
    fluidRow(
      column(width = 6,
             div(id="gmap",
                 leaflet::leafletOutput("map")
             )
      ),
      column(width = 6,
             div(align = "center", h6("Results")),
             conditionalPanel(condition = "input.mode == 'sAsS' || input.mode == 'xAsS'",
                              wellPanel(
                                htmlOutput("results")
                              )),
             conditionalPanel(condition = "input.mode == 'sAxS'",
                              DT::DTOutput("resultsTable")
             )
      )
    ),
    includeCSS("./www/style.css")
  )
}
