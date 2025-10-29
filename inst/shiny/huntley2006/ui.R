## UI.R
function(request) {
  fluidPage(
    titlePanel("Huntley (2006)", windowTitle = "RLumShiny - Huntley (2006)"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 5,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Import",
                               # Tab 1: Data input
                               RLumShiny:::importTab("import",
                                                     "CSV file with three columns (Dose [s], LxTx and LxTx.Error)",
                                                     "text/csv, .csv",
                                                     callback = function() {
                                                       # rhandsontable input/output
                                                       fluidRow(
                                                           column(width = 6,
                                                                  rHandsontableOutput(outputId = "table_in_primary")
                                                                  )
                                                       )
                                                     }
                               ), ## EndOf::Tab_1

                               tabPanel("Method",
                                        withMathJax(),
                                        div(align = "center", h5("Rho prime")),
                                        fluidRow(
                                          column(width = 6,
                                                 numericInput(inputId = "rhop",
                                                              label = "Density of recombination centres, \\(\\rho'\\)",
                                                              value = 4.1e-6,
                                                              min = 0,
                                                              step = 1e-7)
                                          ),
                                          column(width = 6,
                                                 numericInput(inputId = "rhop_error",
                                                              label = "Error",
                                                              value = 5.2e-7,
                                                              min = 0,
                                                              step = 1e-8)
                                          )
                                        ),

                                        div(align = "center", h5("Dose rates")),
                                        fluidRow(
                                          column(width = 6,
                                                 numericInput(inputId = "ddot",
                                                              label = "Environmental dose rate, \\(\\dot{D}\\) (Gy/ka)",
                                                              value = 7,
                                                              min = 0.1,
                                                              step = 0.1)
                                          ),
                                          column(width = 6,
                                                 numericInput(inputId = "ddot_error",
                                                              label = "Error",
                                                              value = 0.04,
                                                              min = 0,
                                                              step = 0.01)
                                          )
                                        ),

                                        fluidRow(
                                          column(width = 6,
                                                 numericInput(inputId = "reader_ddot",
                                                              label = "Reader dose rate (Gy/s)",
                                                              value = 0.13,
                                                              min = 0,
                                                              step = 0.01),
                                                 title = "Dose rate of the irradiation source of the OSL reader.",
                                          ),
                                          column(width = 6,
                                                 numericInput(inputId = "reader_ddot_error",
                                                              label = "Error",
                                                              value = 0.006,
                                                              min = 0,
                                                              step = 0.001)
                                          )
                                        ),

                                        div(align = "center", h5("Model")),

                                        fluidRow(
                                          column(width = 6,
                                                 radioButtons(inputId = "fit_method",
                                                              label = "Fit method",
                                                              selected = "EXP",
                                                              choices = c("Single saturating exponential (EXP)" = "EXP",
                                                                          "General-order kinetics (GOK)" = "GOK")
                                                              )
                                          ),
                                          column(width = 6,
                                                 numericInput(inputId = "n_MC",
                                                              label = "Monte Carlo iterations",
                                                              value = 2,
                                                              min = 2,
                                                              step = 500)
                                          )
                                        ),

                                        div(align = "center", h5("Dose response curves")),
                                        fluidRow(
                                          column(width = 6,
                                                 radioButtons(inputId = "mode",
                                                              label = "De computation mode",
                                                              selected = "interpolation",
                                                              choices = c(interpolation = "interpolation",
                                                                          extrapolation = "extrapolation",
                                                                          alternate = "alternate")
                                                              )
                                          ),
                                          column(width = 6,
                                                 checkboxInput(inputId = "fit_bounds",
                                                               label = "Fit bounds",
                                                               value = TRUE),
                                                 checkboxInput(inputId = "fit_force_through_origin",
                                                               label = "Force fit through origin",
                                                               value = FALSE)
                                          )
                                        )
                               ),

                               tabPanel("Plot",
                                        div(align = "center", h5("Plot elements")),
                                        textInput(inputId = "main",
                                                  label = "Title",
                                                  value = "Dose response curves"),

                                        checkboxInput(inputId = "summary",
                                                      label = "Show summary",
                                                      value = TRUE),

                                        div(align = "center", h5("Axes")),
                                        textInput(inputId = "xlab",
                                                  label = "Label x-axis",
                                                  value = "Dose [Gy]"),

                                        textInput(inputId = "ylab",
                                                  label = "Label y-axis",
                                                  value = "LxTx [a.u.]"),

                                        checkboxInput(inputId = "normalise",
                                                      "Normalise y-axis",
                                                      value = FALSE),

                                        div(align = "center", h5("Scaling")),
                                        sliderInput(inputId = "cex",
                                                    label = "Scaling factor",
                                                    min = 0.5, max = 2,
                                                    value = 1.0, step = 0.1)

                               ),##EndOf::Tab_3
                               RLumShiny:::exportTab("export", filename = "huntley2006"),
                               RLumShiny:::aboutTab("about", "huntley2006")
                   )##EndOf::tabsetPanel
      ),##EndOf::sidebarPanel

      # 3 - output panel
      mainPanel(width = 7,
                # insert css code inside <head></head> of the generated HTML file:
                # allow open dropdown menus to reach over the container
                tags$head(tags$style(type="text/css",".tab-content {overflow: visible;}")),
                tags$head(includeCSS("www/style.css")),
                # divide output in separate tabs via tabsetPanel
                fluidRow(
                  tabsetPanel(
                    tabPanel("Results",
                             plotOutput(outputId = "main_plot", height = "500px"),
                             htmlOutput(outputId = "results")
                             ),
                    tabPanel("R code", verbatimTextOutput("plotCode"))
                  )
                )
      )##EndOf::mainPanel
    ),##EndOf::sideBarLayout
    bookmarkButton()
  )##EndOf::fluidPage
}
