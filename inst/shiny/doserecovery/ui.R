function(request) {
  fluidPage(
    titlePanel("Dose Recovery", windowTitle = "RLumShiny - Dose Recovery"),
    sidebarLayout(
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
                                        div(align = "left",
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
                                                                                "Bottom right" = "bottomright"))),
                                            title = "Position of the statistical summary. The keyword \"Subtitle\" will only work if no plot subtitle is used."),
                                        div(align = "left",
                                            checkboxGroupInput(inputId = "stats",
                                                               label = "Parameters",
                                                               selected = c("n","mean"),
                                                               choices = c("n" = "n",
                                                                           "Mean" = "mean",
                                                                           "weighted Mean" = "weighted$mean",
                                                                           "Median" = "median",
                                                                           #"weighted Median" = "median.weighted",
                                                                           "rel. Standard deviation" = "sd.rel",
                                                                           "abs. Standard deviation" = "sd.abs",
                                                                           "rel. Standard error" = "se.rel",
                                                                           "abs. Standard error" = "se.abs",
                                                                           #"25 % Quartile" = "q25", #not implemented yet
                                                                           #"75 % Quartile" = "q75", #not implemented yet
                                                                           "Skewness" = "skewness",
                                                                           "Kurtosis" = "kurtosis")),
                                            title = "Statistical parameters to be shown in the summary.")
                               ),##EndOf::Tab_2

                               # Tab 3: input that refer to the plot rather than the data
                               tabPanel("DRT Details",
                                        div(align = "center", h5("Experimental details")),
                                        div(align = "left",
                                            numericInput(inputId = "dose",
                                                         label = "Given dose (primary data set)",
                                                         value = 2800),
                                            title = "Given dose used for the dose recovery test to normalise data. If set to 0, values are plotted without normalisation (might be useful for preheat plateau tests). Note: Unit has to be the same as from the input values (e.g., Seconds or Gray)."),
                                        numericInput(inputId = "dose2", label = "Given dose (secondary data set)", value = 3000),
                                        div(align = "center", h5("Preheat temperatures")),
                                        div(align = "left",
                                            checkboxInput(inputId = "preheat",
                                                          label = "Group values by preheat temperature",
                                                          value = FALSE),
                                            title = "Optional preheat temperatures to be used for grouping the De values. If specified, the temperatures are assigned to the x-axis."),
                                        conditionalPanel(condition = 'input.preheat == true',
                                                         div(align = "left",
                                                             checkboxInput(inputId = "boxplot",
                                                                           label = "Show as boxplot",
                                                                           value = FALSE),
                                                             title = "Plot values that are grouped by preheat temperature as boxplots."),

                                                         numericInput(inputId = "ph1", "PH Temperature #1", 180, min = 0),
                                                         numericInput(inputId = "ph2", "PH Temperature #2", 200, min = 0),
                                                         numericInput(inputId = "ph3", "PH Temperature #3", 220, min = 0),
                                                         numericInput(inputId = "ph4", "PH Temperature #4", 240, min = 0),
                                                         numericInput(inputId = "ph5", "PH Temperature #5", 260, min = 0),
                                                         numericInput(inputId = "ph6", "PH Temperature #6", 280, min = 0),
                                                         numericInput(inputId = "ph7", "PH Temperature #7", 300, min = 0),
                                                         numericInput(inputId = "ph8", "PH Temperature #8", 320, min = 0)
                                        )
                               ),##EndOf::Tab_3

                               # Tab 3: input that refer to the plot rather than the data
                               tabPanel("Plot",
                                        div(align = "center", h5("Title")),
                                        fluidRow(
                                          column(width = 6,
                                                 textInput(inputId = "main",
                                                           label = "Title",
                                                           value = "DRT Plot")
                                          ),
                                          column(width = 6,
                                                 textInput(inputId = "mtext",
                                                           label = "Subtitle",
                                                           value = "")
                                          )
                                        ),

                                        div(align = "center", h5("Error range")),
                                        div(align = "left",
                                            numericInput(inputId = "error",
                                                         label = "Symmetric error range (%)",
                                                         value = 10, min = 0, max = 100, step = 1),
                                            title = "Symmetric error range in percent that will be shown as dashed lines in the plot. It can be set to 0 to remove the error ranges."),

                                        div(align = "center", h5("Scaling")),
                                        sliderInput(inputId = "cex",
                                                    label = "Scaling factor",
                                                    min = 0.5, max = 2,
                                                    value = 1.0, step = 0.1)
                               ),##EndOf::Tab_3

                               # Tab 4: modify axis parameters
                               tabPanel("Axis",
                                        div(align = "center", h5("X-axis")),
                                        textInput(inputId = "xlab",
                                                  label = "Label x-axis",
                                                  value = "# Aliquot"),
                                        # inject xlim sliderInput from server.R
                                        conditionalPanel(condition = 'input.preheat != true',
                                                         uiOutput(outputId = "xlim")
                                        ),
                                        br(),
                                        div(align = "center", h5("Y-axis")),
                                        textInput(inputId = "ylab",
                                                  label = "Label y-axis",
                                                  value = "Normalised De"),
                                        # inject ylim sliderInput from server.R
                                        uiOutput(outputId = "ylim")
                               ),##EndOf::Tab_4

                               tabPanel("Datapoints",
                                        div(align = "center", h5("Primary data set")),
                                        fluidRow(
                                          column(width = 6,
                                                 RLumShiny:::pointSymbolChooser(inputId = "pch",
                                                                    label = "Style",
                                                                    selected = "16")
                                          ),
                                          column(width = 6,
                                                 # show only if custom symbol is desired
                                                 conditionalPanel(condition = "input.pch == 'custom'",
                                                                  RLumShiny:::customSymbolChooser(inputId = "custompch")
                                                                  )
                                          )
                                        ),
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
                                        br(),
                                        div(align = "center", h5("Secondary data set")),
                                        fluidRow(
                                          column(width = 6,
                                                 ## DATA SET 2
                                                 RLumShiny:::pointSymbolChooser(inputId = "pch2",
                                                                    label = "Style",
                                                                    selected = "16")
                                          ),
                                          column(width = 6,
                                                 # show only if custom symbol is desired
                                                 conditionalPanel(condition = "input.pch2 == 'custom'",
                                                                  RLumShiny:::customSymbolChooser(inputId = "custompch2")
                                                                  )
                                          )
                                        ),
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

                               # Tab xy: add and customize legend
                               tabPanel("Legend",
                                        div(align = "center", h5("Legend")),
                                        fluidRow(
                                          column(width = 6,
                                                 checkboxInput(inputId = "showlegend",
                                                               label = "Show legend",
                                                               value = TRUE),
                                                 title = "Legend content to be added to the plot.")
                                          ),
                                        fluidRow(
                                          column(width = 6,
                                                 textInput(inputId = "legendname",
                                                           label = "Primary data label",
                                                           value = "primary data")
                                          ),
                                          column(width = 6,
                                                 textInput(inputId = "legendname2",
                                                           label = "Secondary data label",
                                                           value = "secondary data")
                                          )
                                        ),
                                        selectInput(inputId = "legend.pos",
                                                    label = "Legend position",
                                                    selected = "bottomleft",
                                                    choices = c("Top" = "top",
                                                                "Top left" = "topleft",
                                                                "Top right"= "topright",
                                                                "Center" = "center",
                                                                "Bottom" = "bottom",
                                                                "Bottom left" = "bottomleft",
                                                                "Bottom right" = "bottomright"))
                               ),##EndOf::Tab_xy

                               RLumShiny:::exportTab("export", filename = "dose recovery"),
                               RLumShiny:::aboutTab("about", "doserecovery")
                   )
      ),


      # Show a plot of the generated distribution
      mainPanel(width = 7,
                # insert css code inside <head></head> of the generated HTML file:
                # allow open dropdown menus to reach over the container
                tags$head(tags$style(type="text/css",".tab-content {overflow: visible;}")),
                tags$head(includeCSS("www/style.css")),
                # divide output in separate tabs via tabsetPanel
                tabsetPanel(
                  tabPanel("Plot", plotOutput(outputId = "main_plot", height = "400px")),
                  tabPanel("Primary data set", fluidRow(column(width = 12, DT::DTOutput("dataset")))),
                  tabPanel("Secondary data set", DT::DTOutput("dataset2")),
                  tabPanel("R plot code", verbatimTextOutput("plotCode"))
                )
      )
    ),
    bookmarkButton()
  )
}
