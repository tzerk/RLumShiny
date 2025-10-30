## UI.R
function(request) {
  fluidPage(
    titlePanel("LM Curve", windowTitle = "RLumShiny - LM Curve"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 5,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Import",
                               # Tab 1: Data input
                               RLumShiny:::importTab("import",
                                                     "CSV file with two columns (Time and Counts)",
                                                     "text/csv, .csv",
                                                     callback = function() {
                                                       list(
                                                           # bg data set file upload
                                                           fileInput(inputId = "file_bg",
                                                                     label = strong("Background data set"),
                                                                     placeholder = "CSV file with two columns (Time and Counts)",
                                                                     accept = "text/csv, .csv"),
                                                           # rhandsontable input/output
                                                           fluidRow(
                                                               column(width = 6,
                                                                      rHandsontableOutput(outputId = "table_in_primary")
                                                                      ),
                                                               column(width = 6,
                                                                      rHandsontableOutput(outputId = "table_bg")
                                                                      )
                                                           )
                                                       )
                                                     }
                               ), ## EndOf::Tab_1

                               tabPanel("Method",
                                        div(align = "center", h5("Fitting")),
                                        sliderInput(inputId = "n_components",
                                                    "Number of components",
                                                    value = 2,
                                                    min = 1,
                                                    max = 7,
                                                    step = 1),

                                        radioButtons(inputId = "bg_subtraction",
                                                     label = "Background subtraction method",
                                                     selected = "polynomial",
                                                     choices = c("polynomial" = "polynomial",
                                                                 "linear" = "linear",
                                                                 "channel" = "channel",
                                                                 "none" = "none")
                                                     ),

                                        div(align = "center", h5("Absolute photoionisation cross-section")),
                                        sliderInput(inputId = "LED_power",
                                                    "LED power (mW/cm²)",
                                                    min = 0, max = 100,
                                                    value = 36,
                                                    step = 1),
                                        sliderInput(inputId = "LED_wavelength",
                                                    "LED wavelength (nm)",
                                                    min = 100, max = 700,
                                                    value = 470,
                                                    step = 1)
                               ),

                               tabPanel("Plot",
                                        div(align = "center", h5("Plot elements")),
                                        textInput(inputId = "main",
                                                  label = "Title",
                                                  value = "LM Curve"),

                                        fluidRow(
                                            column(width = 6,
                                                   checkboxInput(inputId = "plot_residuals",
                                                                 label = "Plot residuals",
                                                                 value = TRUE)
                                                   ),
                                            column(width = 6,
                                                   checkboxInput(inputId = "plot_contribution",
                                                                 label = "Plot component contribution",
                                                                 value = TRUE)
                                                   )
                                        ),

                                        br(),
                                        div(align = "center", h5("Axes")),

                                        radioButtons(inputId = "datatype",
                                                     label = "Input data type",
                                                     selected = "LM",
                                                     choices = c("LM" = "LM",
                                                                 "pseudo LM" = "pLM")
                                                     ),

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
                                                                "Center" = "center",
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

                               RLumShiny:::exportTab("export", filename = "lmcurve"),
                               RLumShiny:::aboutTab("about", "lmcurve")
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
                    tabPanel("Photoionisation cross-section", DT::DTOutput("CS")),
                    tabPanel("R code", verbatimTextOutput("plotCode"))
                  )
                )
      )##EndOf::mainPanel
    ),##EndOf::sideBarLayout
    bookmarkButton()
  )##EndOf::fluidPage
}
