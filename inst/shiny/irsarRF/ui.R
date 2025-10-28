## UI.R
function(request) {
  fluidPage(
    titlePanel("IRSAR RF", windowTitle = "RLumShiny - IRSAR RF"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 5,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Data",
                               # Tab 1: Data input
                               tabPanel("Data",
                                        div(align = "center", h5("Data upload")),
                                        fileInput(inputId = "nat",
                                                  label = strong("Natural curve"),
                                                  placeholder = "A CSV file with two columns (Time and Counts)",
                                                  accept="text/plain, .csv, text/csv"),
                                        fileInput(inputId = "reg",
                                                  label = strong("Regenerated curve"),
                                                  placeholder = "A CSV file with two columns (Time and Counts)",
                                                  accept="text/plain, .csv, text/csv"),

                                        # rhandsontable input/output
                                        fluidRow(
                                          column(width = 6,
                                                 rHandsontableOutput(outputId = "table_natural")
                                          ),
                                          column(width = 6,
                                                 rHandsontableOutput(outputId = "table_regenerated")
                                          )
                                        )

                               ),##EndOf::Tab_1

                               tabPanel("Method",
                                        div(align = "center", h5("Method")),
                                        selectInput(inputId = "method",
                                                    label = "Method",
                                                    selected = "SLIDE",
                                                    choices = c("SLIDE",
                                                                "VSLIDE",
                                                                "FIT",
                                                                "NONE")
                                                    ),

                                        br(),
                                        div(align = "center", h5("Channel ranges")),
                                        div(align = "left",
                                            uiOutput(outputId = "RF_nat"),
                                            title = "Set minimum and maximum channel range for natural signal fitting and sliding."),

                                        div(align = "left",
                                            uiOutput(outputId = "RF_reg"),
                                            title = "Set minimum and maximum channel range for regenerated signal fitting and sliding."),

                                        br(),
                                        div(align = "center", h5("Other options")),
                                        div(align = "left",
                                            numericInput(inputId = "n_MC",
                                                         label = "Monte Carlo iterations",
                                                         value = 10, step = 10,
                                                         min = 0, max = 100),
                                            title = "Number of Monte Carlo runs for the estimation of the start parameter (FIT) or of the error (SLIDE and VSLIDE). This value can be set to 0 to skip the MC runs.")
                               ),

                               tabPanel("Plot",
                                        div(align = "center", h5("Plot elements")),
                                        textInput(inputId = "main",
                                                  label = "Title",
                                                  value = "IR-RF"),
                                        conditionalPanel(condition = "input.method != 'NONE'",
                                                         checkboxInput(inputId = "show_residuals",
                                                                       label = "Show residuals",
                                                                       value = TRUE)
                                                        ),
                                        conditionalPanel(condition = "input.method == 'SLIDE' | input.method == 'VSLIDE'",
                                                         checkboxInput(inputId = "show_density",
                                                                       label = "Show density",
                                                                       value = TRUE),
                                                         checkboxInput(inputId = "show_fit",
                                                                       label = "Show fit",
                                                                       value = FALSE),
                                                         ),

                                        div(align = "center", h5("Legend")),
                                        checkboxInput(inputId = "legend",
                                                      label = "Show legend",
                                                      value = TRUE),

                                        selectInput(inputId = "legend_pos",
                                                    label = "Legend position",
                                                    selected = "top",
                                                    choices = c("Top" = "top",
                                                                "Top left" = "topleft",
                                                                "Top right"= "topright",
                                                                "Center" = "center",
                                                                "Bottom" = "bottom",
                                                                "Bottom left" = "bottomleft",
                                                                "Bottom right" = "bottomright")),

                                        div(align = "center", h5("Scaling")),
                                        sliderInput(inputId = "cex",
                                                    label = "Scaling factor",
                                                    min = 0.5, max = 2,
                                                    value = 1.0, step = 0.1)

                               ),##EndOf::Tab_3

                               tabPanel("Axis",
                                        div(align = "center", h5("X-axis")),
                                        checkboxInput(inputId = "logx",
                                                      label = "Logarithmic x-axis",
                                                      value = FALSE),
                                        textInput(inputId = "xlab",
                                                  label = "Label x-axis",
                                                  value = "Time [s]"),

                                        div(align = "center", h5("Y-axis")),
                                        ## inject ylab textInput from server.R
                                        checkboxInput(inputId = "logy",
                                                      label = "Logarithmic y-axis",
                                                      value = FALSE),
                                        uiOutput(outputId = "ylab")
                               ),
                               RLumShiny:::exportTab("export", filename = "irsarRF"),
                               RLumShiny:::aboutTab("about", "irsarRF")
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
                             plotOutput(outputId = "main_plot", height = "600px"),
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
