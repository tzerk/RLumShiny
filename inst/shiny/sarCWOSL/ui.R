## UI.R
function(request) {

  ## helper to wrap a sidebar section in a bordered panel with its header on top
  section <- function(title, ...) {
    div(class = "section-panel",
        h5(title, class = "section-header"),
        ...)
  }

  fluidPage(
    titlePanel("SAR CWOSL", windowTitle = "RLumShiny - SAR CWOSL"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 4,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Import",
                               # Tab 1: Data input
                               RLumShiny:::importTab("import",
                                                     "XSYG file (.xsyg) or BIN/BINX (.bin/.binx)",
                                                     "application/xml, .xsyg, application/octet-stream, .bin, .binx",
                                                     callback = function() {

                                   list(
                                       section("Aliquot and record type selection",
                                           uiOutput("positions"),
                                           uiOutput("recordTypes")
                                       ),

                                       section("(De)select individual curves",
                                           fluidRow(
                                               column(width = 5,
                                                      rhandsontable::rHandsontableOutput("curves")
                                               ),
                                               column(width = 7,
                                                      plotly::plotlyOutput("curve_plot", height = "320px")
                                               )
                                           )
                                       ),

                                       section("Batch processing",
                                           actionButton("analyze_all",
                                                        icon = icon("play"),
                                                        label = "Analyze all"),
                                           actionButton("clear_results",
                                                        icon = icon("trash-can"),
                                                        label = "Clear results")
                                       )
                                   )
                               }),

                               tabPanel("Method",
                                        section("Input data preprocessing",
                                        sliderInput(inputId = "signal_integral",
                                                    "Signal integral",
                                                    value = c(1, 5),
                                                    min = 1,
                                                    max = 1000,
                                                    step = 1,
                                                    dragRange = TRUE),
                                        checkboxInput(inputId = "sub_bg_integral",
                                                      label = "Subtract the background integral",
                                                      value = TRUE),
                                        conditionalPanel(condition = "input.sub_bg_integral == true",
                                            sliderInput(inputId = "background_integral",
                                                    "Background integral",
                                                    value = c(900, 1000),
                                                    min = 1,
                                                    max = 1000,
                                                    step = 1,
                                                    dragRange = TRUE)
                                        ),
                                        radioButtons(inputId = "mode",
                                                     label = "Mode",
                                                     selected = "interpolation",
                                                     choices = c("interpolation" = "interpolation",
                                                                 "extrapolation" = "extrapolation")
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
                                                                   "OTOR" = "OTOR"))
                                         )
                               ),

                               tabPanel("Plot",
                                        section("Plot elements",
                                            textInput(inputId = "main",
                                                      label = "Title",
                                                      value = ""),
                                            checkboxInput(inputId = "abanico_mark",
                                                          label = "Mark current position in Abanico plot",
                                                          value = TRUE)
                                        ),

                                        section("Axes",
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

                                        section("Dose response curve",
                                            fluidRow(
                                                column(width = 6,
                                                       checkboxInput(inputId = "showlegend",
                                                                     label = "Show legend",
                                                                     value = TRUE)
                                                       ),
                                                column(width = 6,
                                                       checkboxInput(inputId = "showrug",
                                                                     label = "Show rug",
                                                                     value = TRUE)
                                                       )
                                            ),
                                            RLumShiny:::legendPositionChooser(inputId = "legend_pos",
                                                                              selected = "topright")
                                        ),

                                        section("Scaling",
                                            sliderInput(inputId = "cex",
                                                        label = "Scaling factor",
                                                        min = 0.5, max = 2,
                                                        value = 1.3, step = 0.1)
                                        )

                               ),##EndOf::Tab_3

                               RLumShiny:::exportTab("export", filename = "sarCWOSL"),
                               RLumShiny:::aboutTab("about", "sarCWOSL")
                   )##EndOf::tabsetPanel
      ),##EndOf::sidebarPanel

      # 3 - output panel
      mainPanel(width = 8,
                # insert css code inside <head></head> of the generated HTML file:
                # allow open dropdown menus to reach over the container
                tags$head(tags$style(type="text/css",".tab-content {overflow: visible;}")),
                tags$head(includeCSS("www/style.css")),
                # divide output in separate tabs via tabsetPanel
                fluidRow(
                  tabsetPanel(
                    tabPanel("Plot",
                             plotOutput(outputId = "main_plot", height = "600px", width = "95%"),
                             # results table (left) and Abanico plot (right) below the SAR plot
                             fluidRow(
                               column(width = 7, DT::DTOutput("results_main")),
                               column(width = 5, plotOutput(outputId = "abanico_plot", height = "400px"))
                             )),
                    tabPanel("Results", DT::DTOutput("results", width = "95%")),
                    tabPanel("Highlights", DT::DTOutput("highlights", width = "95%")),
                    tabPanel("R code", verbatimTextOutput("plotCode"))
                  )
                )
      )##EndOf::mainPanel
    ),##EndOf::sideBarLayout
    bookmarkButton()
  )##EndOf::fluidPage
}
