## UI.R
function(request) {
  fluidPage(
    titlePanel("Abanico Plot", windowTitle = "RLumShiny - Abanico Plot"),
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
                                                               value = TRUE),
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
                                                                                     "Bottom right" = "bottomright"))),
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
                                            title = "Method used to calculate the statistic summary. See calc_Statistics for details."),

                                        helpText(tags$b("NOTE:"),
                                                 tags$a(
                                                   href = "https://github.com/R-Lum/Luminescence/issues/50", target = "_blank",
                                                   HTML("The statistical parameters are calculated on the <b>logged</b> D<sub>E</sub> values",
                                                        "if <code>log.z = TRUE</code> (the default, see <i>'Axis' > 'Logarithmic z-axis'</i>).</href>")

                                        )),
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
                                            title = "Statistical parameters to be shown in the summary."),
                                        br(),
                                        div(align = "center", h5("Datapoint labels")),
                                        div(align = "center", checkboxGroupInput(inputId = "statlabels", inline = TRUE,
                                                                                 label = NULL,
                                                                                 choices = c("Min" = "min",
                                                                                             "Max" = "max",
                                                                                             "Median" = "median")),
                                            title = "Additional labels of statistically important values in the plot."),
                                        br(),
                                        div(align = "center", h5("Error bars")),
                                        div(align = "left",
                                            checkboxInput(inputId = "errorbars",
                                                          label = "Show error bars",
                                                          value = FALSE),
                                            title = "Show De-errors as error bars on De-points. Useful in combination with hidden y-axis and 2σ bar.")
                               ),##EndOf::Tab_2

                               # Tab 3: input that refer to the plot rather than the data
                               tabPanel("Plot",
                                        div(align = "center", h5("Title")),
                                        fluidRow(
                                          column(width = 6,
                                                 textInput(inputId = "main",
                                                           label = "Title",
                                                           value = "Abanico Plot")
                                          ),
                                          column(width = 6,
                                                 textInput(inputId = "mtext",
                                                           label = "Subtitle",
                                                           value = "")
                                          )
                                        ),
                                        div(align = "center", h5("Scaling")),
                                        # inject sliderInput from Server.R
                                        div(id="bwKDE",
                                            uiOutput(outputId = "bw"),
                                            title = "Bin width of the kernel density estimate."
                                        ),
                                        fluidRow(
                                          column(width = 6,
                                                 div(id="pratiodiv",
                                                     sliderInput(inputId = "p.ratio",
                                                                 label = "Plot ratio",
                                                                 min=0.25, max=0.90,
                                                                 value=0.75, step=0.01, round= FALSE)
                                                 ),
                                                 title = "Relative space given to the radial versus the cartesian plot part, default is 0.75."
                                          ),
                                          column(width = 6,
                                                 sliderInput(inputId = "cex",
                                                             label = "Scaling factor",
                                                             min = 0.5, max = 2,
                                                             value = 1.0, step = 0.1)
                                          )
                                        ),
                                        br(),
                                        div(align = "center", h5("Centrality")),
                                        div(align = "left",
                                            # centrality can either be a keyword or numerical input
                                            selectInput(inputId = "centrality",
                                                        label = "Central Value",
                                                        list("Mean" = "mean",
                                                             "Median" = "median",
                                                             "Weighted mean" = "mean.weighted",
                                                             "Custom value" = "custom")),
                                            title = "User-defined central value, used for centering of data."),

                                        conditionalPanel(condition = "input.centrality == 'custom'",
                                                         uiOutput("centralityNumeric")),

                                        div(align = "center", h5("Dispersion")),
                                        div(align = "left",
                                            selectInput(inputId = "dispersion",
                                                        label = "Measure of dispersion",
                                                        list("Quartile range" = "qr",
                                                             "1 sigma" = "sd",
                                                             "2 sigma" = "2sd",
                                                             "Custom percentile range" = "custom")),
                                            title = "Measure of dispersion, used for drawing the polygon that depicts the spread in the dose distribution."),

                                        conditionalPanel(condition = "input.dispersion == 'custom'",
                                                         numericInput(inputId = "cinn",
                                                                      label = "x % percentile",
                                                                      value = 25,
                                                                      min = 0,
                                                                      max = 100,
                                                                      step = 1)),

                                        div(align = "center", HTML("<h5>2&sigma; bar</h5>")),

                                        fluidRow(
                                          column(width = 6,
                                                 checkboxInput(inputId = "customSigBar",
                                                               label = HTML("Customise 2&sigma; bar"),
                                                               value = FALSE)
                                          ),
                                          column(width = 6,
                                                 checkboxInput(inputId = "addBar",
                                                               label = HTML("Second 2&sigma; bar"),
                                                               value = FALSE)
                                          )
                                        ),


                                        fluidRow(
                                          column(width = 6,
                                                 conditionalPanel(condition = "input.customSigBar == true",
                                                                  numericInput(inputId = "sigmabar1",
                                                                               label = HTML("2&sigma; bar 1"),
                                                                               min = 0, max = 100,
                                                                               value = 60)
                                                 )
                                          ),
                                          column(width = 6,
                                                 conditionalPanel(condition = "input.customSigBar == true",
                                                                  numericInput(inputId = "sigmabar2",
                                                                               label = HTML("2&sigma; bar 2"),
                                                                               min = 0, max = 100,
                                                                               value = 100)
                                                 )
                                          )
                                        ),

                                        div(align = "center", h5("Central line")),

                                        fluidRow(
                                          column(width = 6,
                                                 numericInput(inputId = "lwd",
                                                              label = "Line width #1",
                                                              min = 0, max = 5,
                                                              value = 1)
                                          ),
                                          column(width = 6,
                                                 numericInput(inputId = "lwd2",
                                                              label = "Line width #2",
                                                              min = 0, max = 5,
                                                              value = 1)
                                          )
                                        ),
                                        fluidRow(
                                          column(width = 6,
                                                 selectInput(inputId = "lty",
                                                             label = "Line type",
                                                             selected = 2,
                                                             choices = list("Blank" = 0,
                                                                            "Solid" = 1,
                                                                            "Dashed" = 2,
                                                                            "Dotted" = 3,
                                                                            "Dot dash" = 4,
                                                                            "Long dash" = 5,
                                                                            "Two dash" = 6))
                                          ),
                                          column(width = 6,
                                                 selectInput(inputId = "lty2",
                                                             label = "Line type",
                                                             selected = 2,
                                                             choices = list("Blank" = 0,
                                                                            "Solid" = 1,
                                                                            "Dashed" = 2,
                                                                            "Dotted" = 3,
                                                                            "Dot dash" = 4,
                                                                            "Long dash" = 5,
                                                                            "Two dash" = 6))

                                          )
                                        ),
                                        div(align = "center", h5("Further options")),
                                        fluidRow(
                                          column(width = 6,
                                                 checkboxInput(inputId = "rug",
                                                               label = "Rug",
                                                               value = FALSE),
                                                 title = "Add a rug to the KDE part to indicate the location of individual values."
                                          ),
                                          column(width = 6,
                                                 checkboxInput(inputId = "rotate",
                                                               label = "Rotate plot",
                                                               value = FALSE),
                                                 title = "Rotate the plot by 90°."
                                          ),
                                          column(width = 6,
                                                 checkboxInput(inputId = "boxplot",
                                                               label = "Boxplot",
                                                               value = FALSE),
                                                 title = "Add a boxplot to the dispersion part."
                                          ),
                                          column(width = 6,
                                                 checkboxInput(inputId = "kde",
                                                               label = "KDE",
                                                               value = TRUE),
                                                 title = "Add a KDE plot to the dispersion part."
                                          ),
                                          column(width = 6,
                                                 checkboxInput(inputId = "histogram",
                                                               label = "Histogram",
                                                               value = TRUE),
                                                 title = "Add a histogram to the dispersion part. Only meaningful when not more than one data set is plotted."
                                          ),
                                          column(width = 6,
                                                 checkboxInput(inputId = "dots",
                                                               label = "Dots",
                                                               value = TRUE),
                                                 title = "Add a dot plot to the dispersion part. If number of dots exceeds space in the dispersion part, a square indicates this."
                                         )
                                        ),
                               ),##EndOf::Tab_3

                               # Tab 4: modify axis parameters
                               tabPanel("Axis",
                                        div(align = "center", h5("X-axis")),
                                        fluidRow(
                                          column(width = 6,
                                                 textInput(inputId = "xlab1",
                                                           label = "Label x-axis (upper)",
                                                           value = "Relative error [%]")
                                          ),
                                          column(width = 6,
                                                 textInput(inputId = "xlab2",
                                                           label = "Label x-axis (lower)",
                                                           value = "Precision")
                                          )
                                        ),
                                        # inject sliderInput from Server.R
                                        uiOutput(outputId = "xlim"),
                                        br(),
                                        div(align = "center", h5("Y-axis")),
                                        div(align = "left",
                                            checkboxInput(inputId = "yaxis",
                                                          label = "Show y-axis",
                                                          value = TRUE),
                                            title = "Hide the y-axis labels. Useful for data with small scatter."),
                                        textInput(inputId = "ylab",
                                                  label = "Label y-axis",
                                                  value = "Standardised estimate"),
                                        uiOutput("ylim"),
                                        br(),
                                        div(align = "center", h5("Z-axis")),
                                        div(align = "left",
                                            checkboxInput(inputId = "logz",
                                                          label = "Logarithmic z-axis",
                                                          value = TRUE),
                                            title = "Display the z-axis in logarithmic scale."),
                                        textInput(inputId = "zlab",
                                                  label = "Label z-axis",
                                                  value = "Equivalent dose [Gy]"),
                                        # inject sliderInput from Server.R
                                        uiOutput(outputId = "zlim")
                               ),##EndOf::Tab_4

                               # Tab 5: modify data point representation
                               tabPanel("Datapoints",
                                        div(align = "center", h5("Primary data set")),
                                        fluidRow(
                                          column(width = 6,
                                                 RLumShiny:::pointSymbolChooser(inputId = "pch",
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
                                                                  HTML("Choose a color<br>"),
                                                                  jscolorInput(inputId = "jscol1"))
                                          )
                                        ),
                                        br(),
                                        div(align = "center", h5("Secondary data set")),
                                        fluidRow(
                                          column(width = 6,
                                                 ## DATA SET 2
                                                 RLumShiny:::pointSymbolChooser(inputId = "pch2",
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
                                                                  HTML("Choose a color<br>"),
                                                                  jscolorInput(inputId = "jscol2"))
                                          )
                                        )
                               ),##EndOf::Tab_5

                               # Tab 6: add additional lines to the plot
                               tabPanel("Lines",
                                        helpText("Here you can add additional lines."),
                                        # options for custom lines:
                                        # 1 - z-value, 2 - color, 3 - label, 4 - line type
                                        # only the options for the first line are shown
                                        fluidRow(
                                          column(width = 6,
                                                 numericInput(inputId = "line1",
                                                              label = strong("Line #1"),
                                                              value =  NA, min = 0),
                                                 title = "Numeric values of the additional lines to be added."
                                          ),
                                          column(width = 6,
                                                 selectInput(inputId = "linelty1",
                                                             label = "Line type",
                                                             selected = 1,
                                                             choices = list("Blank" = 0,
                                                                            "Solid" = 1,
                                                                            "Dashed" = 2,
                                                                            "Dotted" = 3,
                                                                            "Dot dash" = 4,
                                                                            "Long dash" = 5,
                                                                            "Two dash" = 6))
                                          )
                                        ),
                                        fluidRow(
                                          column(width = 6,
                                                 HTML("Choose a color<br>"),
                                                 jscolorInput(inputId = "colline1")
                                          ),
                                          column(width = 6,
                                                 textInput(inputId = "labline1",
                                                           label = "Label",
                                                           value = "")
                                          )
                                        ),
                                        # conditional chain: if valid input (i.e. the z-value is > 0) is provided
                                        # for the previous line, show options for a new line (currently up to eight)
                                        conditionalPanel(condition = "input.line1 > 0",
                                                         fluidRow(
                                                           column(width = 6, numericInput(inputId = "line2", strong("Line #2"), NA, min = 0)),
                                                           column(width = 6, selectInput(inputId = "linelty2", label = "Line type",selected = 1,
                                                                                         choices = list("Blank" = 0,
                                                                                                        "Solid" = 1,
                                                                                                        "Dashed" = 2,
                                                                                                        "Dotted" = 3,
                                                                                                        "Dot dash" = 4,
                                                                                                        "Long dash" = 5,
                                                                                                        "Two dash" = 6)))
                                                         ),
                                                         fluidRow(
                                                           column(width = 6, HTML("Choose a color<br>"),jscolorInput(inputId = "colline2")),
                                                           column(width = 6, textInput("labline2","Label",value = ""))
                                                         )
                                        ),
                                        conditionalPanel(condition = "input.line2 > 0",
                                                         fluidRow(
                                                           column(width = 6, numericInput(inputId = "line3", strong("Line #3"), NA, min = 0)),
                                                           column(width = 6, selectInput(inputId = "linelty3", label = "Line type",selected = 1,
                                                                                         choices = list("Blank" = 0,
                                                                                                        "Solid" = 1,
                                                                                                        "Dashed" = 2,
                                                                                                        "Dotted" = 3,
                                                                                                        "Dot dash" = 4,
                                                                                                        "Long dash" = 5,
                                                                                                        "Two dash" = 6)))
                                                         ),
                                                         fluidRow(
                                                           column(width = 6, HTML("Choose a color<br>"),jscolorInput(inputId = "colline3")),
                                                           column(width = 6, textInput("labline3","Label",value = ""))
                                                         )
                                        ),
                                        conditionalPanel(condition = "input.line3 > 0",
                                                         fluidRow(
                                                           column(width = 6, numericInput(inputId = "line4", strong("Line #4"), NA, min = 0)),
                                                           column(width = 6, selectInput(inputId = "linelty4", label = "Line type",selected = 1,
                                                                                         choices = list("Blank" = 0,
                                                                                                        "Solid" = 1,
                                                                                                        "Dashed" = 2,
                                                                                                        "Dotted" = 3,
                                                                                                        "Dot dash" = 4,
                                                                                                        "Long dash" = 5,
                                                                                                        "Two dash" = 6)))
                                                         ),
                                                         fluidRow(
                                                           column(width = 6, HTML("Choose a color<br>"),jscolorInput(inputId = "colline4")),
                                                           column(width = 6, textInput("labline4","Label",value = ""))
                                                         )
                                        ),
                                        conditionalPanel(condition = "input.line4 > 0",
                                                         fluidRow(
                                                           column(width = 6, numericInput(inputId = "line5", strong("Line #5"), NA, min = 0)),
                                                           column(width = 6, selectInput(inputId = "linelty5", label = "Line type",selected = 1,
                                                                                         choices = list("Blank" = 0,
                                                                                                        "Solid" = 1,
                                                                                                        "Dashed" = 2,
                                                                                                        "Dotted" = 3,
                                                                                                        "Dot dash" = 4,
                                                                                                        "Long dash" = 5,
                                                                                                        "Two dash" = 6)))
                                                         ),
                                                         fluidRow(
                                                           column(width = 6, HTML("Choose a color<br>"),jscolorInput(inputId = "colline5")),
                                                           column(width = 6, textInput("labline5","Label",value = ""))
                                                         )
                                        ),
                                        conditionalPanel(condition = "input.line5 > 0",
                                                         fluidRow(
                                                           column(width = 6, numericInput(inputId = "line6", strong("Line #6"), NA, min = 0)),
                                                           column(width = 6, selectInput(inputId = "linelty6", label = "Line type",selected = 1,
                                                                                         choices = list("Blank" = 0,
                                                                                                        "Solid" = 1,
                                                                                                        "Dashed" = 2,
                                                                                                        "Dotted" = 3,
                                                                                                        "Dot dash" = 4,
                                                                                                        "Long dash" = 5,
                                                                                                        "Two dash" = 6)))
                                                         ),
                                                         fluidRow(
                                                           column(width = 6, HTML("Choose a color<br>"),jscolorInput(inputId = "colline6")),
                                                           column(width = 6, textInput("labline6","Label",value = ""))
                                                         )
                                        ),
                                        conditionalPanel(condition = "input.line6 > 0",
                                                         fluidRow(
                                                           column(width = 6, numericInput(inputId = "line7", strong("Line #7"), NA, min = 0)),
                                                           column(width = 6, selectInput(inputId = "linelty7", label = "Line type",selected = 1,
                                                                                         choices = list("Blank" = 0,
                                                                                                        "Solid" = 1,
                                                                                                        "Dashed" = 2,
                                                                                                        "Dotted" = 3,
                                                                                                        "Dot dash" = 4,
                                                                                                        "Long dash" = 5,
                                                                                                        "Two dash" = 6)))
                                                         ),
                                                         fluidRow(
                                                           column(width = 6, HTML("Choose a color<br>"),jscolorInput(inputId = "colline7")),
                                                           column(width = 6, textInput("labline7","Label",value = ""))
                                                         )
                                        ),
                                        conditionalPanel(condition = "input.line7 > 0",
                                                         fluidRow(
                                                           column(width = 6, numericInput(inputId = "line8", strong("Line #8"), NA, min = 0)),
                                                           column(width = 6, selectInput(inputId = "linelty8", label = "Line type",selected = 1,
                                                                                         choices = list("Blank" = 0,
                                                                                                        "Solid" = 1,
                                                                                                        "Dashed" = 2,
                                                                                                        "Dotted" = 3,
                                                                                                        "Dot dash" = 4,
                                                                                                        "Long dash" = 5,
                                                                                                        "Two dash" = 6)))
                                                         ),
                                                         fluidRow(
                                                           column(width = 6, HTML("Choose a color<br>"),jscolorInput(inputId = "colline8")),
                                                           column(width = 6, textInput("labline8","Label",value = ""))
                                                         )
                                        )
                               ),##EndOf::Tab_6

                               # Tab 7: modify the 2-sigma bar (radial plot), grid (both) and polygon (KDE)
                               tabPanel("Bars & Grid",
                                        div(align = "center", h5("Dispersion bar")),
                                        fluidRow(
                                          column(width = 6,
                                                 selectInput(inputId = "polygon",
                                                             label = "Dispersion bar color #1",
                                                             choices = list("Grey" = "grey80",
                                                                            "Custom" = "custom",
                                                                            "None" = "none")),
                                                 title = "Colour of the polygon showing the dose dispersion around the central value."
                                          ),
                                          column(width = 6,
                                                 selectInput(inputId = "polygon2",
                                                             label = "Dispersion bar color #2",
                                                             choices = list("Grey" = "grey80",
                                                                            "Custom" = "custom",
                                                                            "None" = "none"))
                                          )
                                        ),
                                        fluidRow(
                                          column(width = 6,
                                                 # show only if custom color is desired
                                                 conditionalPanel(condition = "input.polygon == 'custom'",
                                                                  jscolorInput(inputId = "rgbPolygon",
                                                                               label = "Choose a color"))
                                          ),
                                          column(width = 6,
                                                 # show only if custom color is desired
                                                 conditionalPanel(condition = "input.polygon2 == 'custom'",
                                                                  jscolorInput(inputId = "rgbPolygon2",
                                                                               label = "Choose a color"))
                                          )
                                        ),
                                        sliderInput(inputId = "alpha.polygon",
                                                    label = "Transparency",
                                                    min = 0, max = 100,
                                                    step = 1, value = 66),
                                        br(),
                                        div(align = "center", HTML("<h5>2&sigma; bar</h5>")),
                                        fluidRow(
                                          column(width = 6,
                                                 selectInput(inputId = "bar", label = HTML("2&sigma; bar color"),
                                                             choices = list("Grey" = "grey50",
                                                                            "Custom" = "custom",
                                                                            "None" = "none")),
                                                 title = "Colour of the bar showing the 2-sigma range of the dose error around the central value."
                                          ),
                                          column(width = 6,
                                                 selectInput(inputId = "bar2", label = HTML("2&sigma; bar color #2"),
                                                             choices = list("Grey" = "grey50",
                                                                            "Custom" = "custom",
                                                                            "None" = "none"))
                                          )
                                        ),
                                        fluidRow(
                                          column(width = 6,
                                                 # show only if custom color is desired
                                                 conditionalPanel(condition = "input.bar == 'custom'",
                                                                  jscolorInput(inputId = "rgbBar",
                                                                               label = "Choose a color"))
                                          ),
                                          column(width = 6,
                                                 # show only if custom color is desired
                                                 conditionalPanel(condition = "input.bar2 == 'custom'",
                                                                  jscolorInput(inputId = "rgbBar2",
                                                                               label = "Choose a color"))
                                          )
                                        ),
                                        sliderInput(inputId = "alpha.bar",
                                                    label = "Transparency",
                                                    min = 0, max = 100,
                                                    step = 1, value = 66),
                                        br(),
                                        div(align = "center", h5("Grid")),
                                        fluidRow(
                                          column(width = 6,
                                                 selectInput(inputId = "grid", label = "Grid color",
                                                             selected = "none",
                                                             list("Grey" = "grey90",
                                                                  "Custom" = "custom",
                                                                  "None" = "none"))
                                          ),
                                          column(width = 6,
                                                 # show only if custom color is desired
                                                 conditionalPanel(condition = "input.grid == 'custom'",
                                                                  jscolorInput(inputId = "rgbGrid",
                                                                               label = "Choose a color"))
                                          )
                                        ),
                                        sliderInput(inputId = "alpha.grid",
                                                    label = "Transparency",
                                                    min = 0, max = 100,
                                                    step = 1, value = 50),

                                        br(),
                                        div(align = "center", h5("Frame")),
                                        selectInput(inputId = "frame", label = "Frame", selected = 1,
                                                    choices = list("No frame" = 0,
                                                                   "Origin at {0,0}" = 1,
                                                                   "Anchors at {0,-2}, {0,2}" = 2,
                                                                   "Rectangle" = 3))
                               ),##EndOf::Tab_7

                               # Tab 8: add and customize legend
                               tabPanel("Legend",
                                        div(align = "center", h5("Legend")),
                                        fluidRow(
                                          column(width = 6,
                                                 checkboxInput(inputId = "showlegend",
                                                               label = "Show legend",
                                                               value = FALSE),
                                                 title = "Legend content to be added to the plot."
                                          ),
                                          column(width = 6,
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
                                          )
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
                                        )
                               ),##EndOf::Tab_8

                               # Tab 9: Filter data
                               tabPanel("Filter",
                                        div(align = "center", h5("Primary data set")),
                                        selectInput(inputId = "filter.prim", label = "Choose values to exclude",
                                                    choices = "", multiple = TRUE, selected = ""),
                                        div(align = "center", h5("Secondary data set")),
                                        selectInput(inputId = "filter.sec", label = "Choose values to exclude",
                                                    choices = "", multiple = TRUE, selected = ""),
                                        actionButton(inputId = "exclude", label = "Exclude")
                               ),##EndOf::Tab_9

                               # Tab 10: Layout
                               tabPanel("Layout",
                                        div(align = "center", h5("Layout")),
                                        div(id = "layout",
                                            selectInput(inputId = "layout",
                                                        label = "Choose layout",
                                                        selected = "default",
                                                        choices = c("Default"="default",
                                                                    "Journal"="journal")),
                                            title = "Allows to modify the entire plot in a more sophisticated manner. Each element of the plot can be addressed and its properties can be defined. This includes font type, size and decoration, colours and sizes of all plot items. To infer the definition of a specific layout style cf. get_Layout() or type eg. for the layout type \"journal\" get_Layout(\"journal\"). A layout type can be modified by the user by assigning new values to the list object."
                                        ),
                               ),

                               RLumShiny:::exportTab("export", filename = "abanico plot"),
                               RLumShiny:::aboutTab("about", "abanico")
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
                  tabPanel("Primary data set", fluidRow(column(width = 12, DT::DTOutput("dataset")))),
                  tabPanel("Secondary data set", DT::DTOutput("dataset2")),
                  tabPanel("Central Age Model", DT::DTOutput("CAM")),
                  tabPanel("R plot code", verbatimTextOutput("plotCode"))
                )###EndOf::tabsetPanel
      )##EndOf::mainPanel
    ),##EndOf::sideBarLayout
    bookmarkButton()
  )##EndOf::fluidPage
}
