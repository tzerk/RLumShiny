## UI.R
function(request) {
  fluidPage(
    titlePanel("Dose Response Curve", windowTitle = "RLumShiny - Dose Response Curve"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 5,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Import",
                               # Tab 1: Data input
                               RLumShiny:::importTab("import",
                                                     "CSV file with at least 3 columns (Dose, LxTx, LxTx.Error and optionally TnTx)",
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

                                        div(align = "center", h5("Fitting")),
                                        radioButtons(inputId = "mode",
                                                     label = "Mode",
                                                     selected = "interpolation",
                                                     choices = c("interpolation" = "interpolation",
                                                                 "extrapolation" = "extrapolation",
                                                                 "alternate" = "alternate")
                                                     ),

                                        selectInput(inputId = "fit_method",
                                                    "Fit method",
                                                    selected = "SSE",
                                                    choices = list("SSE" = "SSE",
                                                                   "LIN" = "LIN",
                                                                   "QDR" = "QDR",
                                                                   "GOK" = "GOK",
                                                                   "SSE OR LIN" = "SSE OR LIN",
                                                                   "SSE+LIN" = "SSE+LIN",
                                                                   "DSE" = "DSE",
                                                                   "OTOR" = "OTOR")),

                                        selectInput(inputId = "fit_weights",
                                                    "Fit weights",
                                                    selected = "inverse_var",
                                                    choices = list("Inverse variance" = "inverse_var",
                                                                   "Inverse standard error" = "inverse_std",
                                                                   "Normalised inverse standard error" = "norm_inverse_std",
                                                                   "None" = "none")),
                                        checkboxInput(inputId = "force_through_origin",
                                                      label = "Force through origin",
                                                      value = TRUE)
                               ),

                               tabPanel("Plot",
                                        div(align = "center", h5("Plot elements")),
                                        textInput(inputId = "main",
                                                  label = "Title",
                                                  value = "Dose Response Curve"),
                                        fluidRow(
                                            column(width = 6,
                                                   checkboxInput(inputId = "extended",
                                                                 label = "Histogram and sensitivity plot",
                                                                 value = TRUE),
                                                   checkboxInput(inputId = "box",
                                                                 label = "Outer box",
                                                                 value = TRUE)
                                                   ),
                                            column(width = 6,
                                                   checkboxInput(inputId = "density_polygon",
                                                                 label = "Density polygon",
                                                                 value = TRUE),
                                                   checkboxInput(inputId = "density_rug",
                                                                 label = "Density rug",
                                                                 value = TRUE)
                                                   )
                                        ),

                                        br(),
                                        div(align = "center", h5("Curve")),
                                        fluidRow(
                                          column(width = 6,
                                                 RLumShiny:::lineTypeChooser(inputId = "lty_drc",
                                                                             selected = 1)
                                          ),
                                          column(width = 6,
                                                 RLumShiny:::lineWidthChooser(inputId = "lwd_drc")
                                          )
                                        ),
                                        fluidRow(
                                            column(width = 6,
                                                   selectInput(inputId = "col_drc",
                                                               label = "Colour",
                                                               selected = "black",
                                                               choices = list("Black" = "black",
                                                                              "Grey" = "grey50",
                                                                              "Red" = "#b22222",
                                                                              "Green" = "#6E8B3D",
                                                                              "Blue" = "#428bca",
                                                                              "Custom" = "custom"))
                                                   ),
                                            column(width = 6,
                                                   # show only if custom color is desired
                                                   conditionalPanel(condition = "input.col_drc == 'custom'",
                                                                    HTML("Choose a colour<br>"),
                                                                    jscolorInput(inputId = "jscol"))
                                                   )
                                        ),

                                        br(),
                                        div(align = "center", h5("Axes")),
                                        textInput(inputId = "xlab",
                                                  label = "Label x-axis",
                                                  value = "Dose [s]"),
                                        textInput(inputId = "ylab",
                                                  label = "Label y-axis",
                                                  value = "Luminescence [a.u.]"),

                                        conditionalPanel(condition = "input.mode != 'extrapolation'",
                                                         fluidRow(
                                                             column(width = 6,
                                                                    checkboxInput(inputId = "logx",
                                                                                  label = "Logarithmic x-axis",
                                                                                  value = FALSE)
                                                                    ),
                                                             column(width = 6,
                                                                    checkboxInput(inputId = "logy",
                                                                                  label = "Logarithmic y-axis",
                                                                                  value = FALSE)
                                                                    )
                                                         )
                                        ),

                                        br(),
                                        div(align = "center", h5("Legend")),
                                        checkboxInput(inputId = "showlegend",
                                                      label = "Show legend",
                                                      value = TRUE),

                                        selectInput(inputId = "legend_pos",
                                                    label = "Legend position",
                                                    selected = "topright",
                                                    choices = c("Top" = "top",
                                                                "Top left" = "topleft",
                                                                "Top right"= "topright",
                                                                "Left" = "left",
                                                                "Center" = "center",
                                                                "Right" = "right",
                                                                "Bottom" = "bottom",
                                                                "Bottom left" = "bottomleft",
                                                                "Bottom right" = "bottomright")),

                                        br(),
                                        div(align = "center", h5("Scaling")),
                                        sliderInput(inputId = "cex",
                                                    label = "Scaling factor",
                                                    min = 0.5, max = 2,
                                                    value = 1.0, step = 0.1)

                               ),##EndOf::Tab_3

                               RLumShiny:::exportTab("export", filename = "doseresponsecurve"),
                               RLumShiny:::aboutTab("about", "doseresponsecurve")
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
                    tabPanel("Plot", plotOutput(outputId = "main_plot", height = "600px")),
                    tabPanel("R code", verbatimTextOutput("plotCode"))
                  )
                )
      )##EndOf::mainPanel
    ),##EndOf::sideBarLayout
    bookmarkButton()
  )##EndOf::fluidPage
}
