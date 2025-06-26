## UI.R
function(request) {
  fluidPage(
    titlePanel(NULL, windowTitle = "RLumShiny - KDE"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 5,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Data",
                               # Tab 1: Data input
                               tabPanel("Data",
                                        # informational text
                                        div(align = "center", h5("Data upload")),

                                        # file upload button (data set 1)
                                        fileInput(inputId = "file1",
                                                  label = strong("Primary data set"),
                                                  placeholder = "A CSV file with two columns (De and De error)",
                                                  accept="text/plain, .csv, text/csv"),
                                        # file upload button (data set 2)
                                        fileInput(inputId = "file2",
                                                  label = strong("Secondary data set"),
                                                  placeholder = "A CSV file with two columns (De and De error)",
                                                  accept="text/plain, .csv, text/csv"),
                                        # rhandsontable input/output
                                        fluidRow(
                                          column(width = 6,
                                                 rHandsontableOutput(outputId = "table_in_primary")
                                          ),
                                          column(width = 6,
                                                 rHandsontableOutput(outputId = "table_in_secondary"))
                                        ),
                                        hr(),
                                        actionButton(inputId = "refresh", label = "Refresh",
                                                     icon = icon("fas fa-sync"), title = "Redraw the plot.")
                               ),##EndOf::Tab_1

                               # Tab 2: Statistical information
                               tabPanel("Statistics",
                                        div(align = "center", h5("Summary")),
                                        fluidRow(
                                          column(width = 6,
                                                 checkboxInput(inputId = "summary",
                                                               label = "Show summary",
                                                               value = FALSE),
                                                 title = "Add numerical output to the plot."
                                          ),
                                          column(width = 6,
                                                 selectInput(inputId = "sumpos",
                                                             label = "Summary position",
                                                             selected = "topleft",
                                                             choices = list("Subtitle" = "sub",
                                                                            "Center" = "center",
                                                                            Top=c("Top" = "top",
                                                                                  "Top left" = "topleft",
                                                                                  "Top right"= "topright"),
                                                                            Bottom=c("Bottom" = "bottom",
                                                                                     "Bottom left" = "bottomleft",
                                                                                     "Bottom right" = "bottomright")
                                                             )),
                                                 title = "Position of the statistical summary. The keyword \"Subtitle\" will only work if no plot subtitle is used."
                                          )
                                        ),
                                        div(align = "left",
                                            selectInput(inputId = "summary.method",
                                                        label = "Summary method",
                                                        selected = "unweighted",
                                                        choices = list("Unweighted" = "unweighted",
                                                                       "Weighted" = "weighted",
                                                                       "Monte Carlo" = "MCM")),
                                            title= "Method used to calculate the statistic summary. See calc_Statistics for details."),

                                        div(align = "left",
                                            checkboxGroupInput(inputId = "stats",
                                                               label = "Parameters",
                                                               selected = c("n","mean"),
                                                               choices = c("n" = "n",
                                                                           "Mean" = "mean",
                                                                           "Median" = "median",
                                                                           "rel. Standard deviation" = "sd.rel",
                                                                           "abs. Standard deviation" = "sd.abs",
                                                                           "rel. Standard error" = "se.rel",
                                                                           "abs. Standard error" = "se.abs",
                                                                           "Skewness" = "skewness",
                                                                           "Kurtosis" = "kurtosis",
                                                                           "% in 2 sigma range" = "in.2s")),
                                            title = "Statistical parameters to be shown in the summary"),

                                        div(align = "center", h5("Additional options")),
                                        div(align = "left",
                                            checkboxInput(inputId = "cumulative",
                                                          label = "Show individual data",
                                                          value = TRUE),
                                            title = "Show cumulative individual data.")

                               ),##EndOf::Tab_2

                               # Tab 3: input that refer to the plot rather than the data
                               tabPanel("Plot",
                                        div(align = "center", h5("Title")),

                                        textInput(inputId = "main",
                                                  label = "Title",
                                                  value = "KDE Plot"),

                                        # inject sliderInput from Server.R
                                        div(align = "left",
                                            uiOutput(outputId = "bw"),
                                            title = "Bin width of the kernel density estimate."),
                                        br(),
                                        div(align = "center", h5("Scaling")),
                                        sliderInput(inputId = "cex",
                                                    label = "Scaling factor",
                                                    min = 0.5, max = 2,
                                                    value = 1.0, step = 0.1),

                                        div(align = "center", h5("Further options")),
                                        fluidRow(
                                          column(width = 6,
                                                 checkboxInput(inputId = "rug",
                                                               label = "Add rug",
                                                               value = TRUE)
                                          ),
                                          column(width = 6,
                                                 checkboxInput(inputId = "boxplot",
                                                               label = "Add boxplot",
                                                               value = TRUE))
                                        )
                               ),##EndOf::Tab_3

                               # Tab 4: modify axis parameters
                               tabPanel("Axis",
                                        div(align = "center", h5("X-axis")),
                                        checkboxInput(inputId = "logx",
                                                      label = "Logarithmic x-axis",
                                                      value = FALSE),
                                        textInput(inputId = "xlab",
                                                  label = "Label x-axis",
                                                  value = "Equivalent dose [Gy]"),
                                        # inject sliderInput from Server.R
                                        uiOutput(outputId = "xlim"),
                                        br(),
                                        div(align = "center", h5("Y-axis")),
                                        fluidRow(
                                          column(width = 6,
                                                 textInput(inputId = "ylab1",
                                                           label = "Label y-axis (left)",
                                                           value = "Density")
                                          ),
                                          column(width = 6,
                                                 textInput(inputId = "ylab2",
                                                           label = "Label y-axis (right)",
                                                           value = "Cumulative frequency")
                                          )
                                        )
                               ),##EndOf::Tab_4

                               # Tab 5: modify data point representation
                               tabPanel("Datapoints",
                                        div(align = "center", h5("Primary data set")),
                                        fluidRow(
                                          column(width = 6,
                                                 selectInput(inputId = "color", label = "Datapoint color",
                                                             choices = list("Black" = "black",
                                                                            "Grey" = "grey50",
                                                                            "Red" = "#b22222",
                                                                            "Green" = "#6E8B3D",
                                                                            "Blue" = "#428bca",
                                                                            "Custom" = "custom"))
                                          ),
                                          column(width = 6,
                                                 # show only if custom color is desired
                                                 conditionalPanel(condition = "input.color == 'custom'",
                                                                  jscolorInput(inputId = "rgb",
                                                                               label = "Choose a color"))
                                          )
                                        ),
                                        div(align = "center", h5("Secondary data set")),
                                        fluidRow(
                                          column(width = 6,
                                                 selectInput(inputId = "color2", label = "Datapoint color",
                                                             selected = "#b22222",
                                                             choices = list("Black" = "black",
                                                                            "Grey" = "grey50",
                                                                            "Red" = "#b22222",
                                                                            "Green" = "#6E8B3D",
                                                                            "Blue" = "#428bca",
                                                                            "Custom" = "custom"))
                                          ),
                                          column(width = 6,
                                                 # show only if custom color is desired
                                                 conditionalPanel(condition = "input.color2 == 'custom'",
                                                                  jscolorInput(inputId = "rgb2",
                                                                               label = "Choose a color"))
                                          )
                                        )
                               ),##EndOf::Tab_5

                               # Tab 9: save plot as pdf, wmf or eps
                               RLumShiny:::exportTab("export", filename = "KDE"),
                               RLumShiny:::aboutTab("about", "KDE")
                   )##EndOf::tabsetPanel
      ),##EndOf::sidebarPanel

      # 3 - output panel
      mainPanel(width = 7,
                # insert css code inside <head></head> of the generated HTML file:
                # allow open dropdown menus to reach over the container
                tags$head(tags$style(type="text/css",".tab-content {overflow: visible;}")),
                tags$head(includeCSS("www/style.css")),
                # divide output in separate tabs via tabsetPanel
                tabsetPanel(
                  tabPanel("Plot", plotOutput(outputId = "main_plot", height = "500px")),
                  tabPanel("Primary data set", DT::DTOutput("dataset")),
                  tabPanel("Secondary data set", DT::DTOutput("dataset2")),
                  tabPanel("Central Age Model", DT::DTOutput("CAM")),
                  tabPanel("R plot code", verbatimTextOutput("plotCode"))
                )###EndOf::tabsetPanel
      )##EndOf::mainPanel
    ),##EndOf::sideBarLayout
    bookmarkButton()
  )#EndOf::fluidPage
}
