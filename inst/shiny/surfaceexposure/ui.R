## UI.R
function(request) {
  fluidPage(
    titlePanel("Surface Exposure", windowTitle = "RLumShiny - Surface Exposure"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 4,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Data",
                               # Tab 1: Data input
                               tabPanel("Data",
                                        RLumShiny:::section("Data upload",
                                        # file upload button (data set 1)
                                        fileInput(inputId = "file",
                                                  label = strong("Primary data set"),
                                                  placeholder = "A CSV file with four columns (Depth [a.u], Signal intensity, Error and Group)",
                                                  accept="text/plain, .csv, text/csv"),
                                        # rhandsontable input/output
                                        rHandsontableOutput(outputId = "table_in_primary"),
                                        helpText(HTML(paste0(
                                          tags$b("NOTE: "), "The uploaded file must have at least two columns (<i>Depth, Signal</i>). ",
                                          "If the file contains three columns, it is automatically assumed that the third column ",
                                          "is the error on the signal. The fourth column (<i>Group</i>) is only required for global fitting ",
                                          "of multiple data sets.")
                                        )))

                               ),##EndOf::Tab_1

                               tabPanel("Fitting",

                                        RLumShiny:::section("Parameters",
                                        fluidRow(
                                          column(width = 4,
                                                 checkboxInput(inputId = "global_fit", "Global fit", TRUE)
                                                 ),
                                          column(width = 4,
                                                 checkboxInput(inputId = "override_mu", "Provide \\( \\mu \\) values", TRUE)
                                                 ),
                                          conditionalPanel(condition = "input.global_fit == true && input.override_mu == true",
                                                           column(width = 4,
                                                                  checkboxInput(inputId = "individual_mus", "Individual \\( \\mu \\) values", TRUE)
                                                           )
                                          )
                                        ),
                                        conditionalPanel(condition = "input.global_fit == true",
                                                         helpText(HTML(paste(tags$b("NOTE:"), "Weighting is not available for global fitting.")))
                                        ),
                                        fluidRow(
                                          column(width = 6,
                                                 uiOutput("global_fit_ages"),
                                                 title = "The age (a) of the sample."
                                                 ),
                                          column(width=6,
                                                 uiOutput("global_fit_mus"),
                                                 title = "The light attenuation coefficient."
                                                 )
                                        ),
                                        conditionalPanel(condition = "input.global_fit == false",
                                                         checkboxInput(inputId = "weights", HTML("Error weighted fitting (1/&sigma;<sup>2</sup>)"), FALSE)
                                        ),
                                        hr(),
                                        conditionalPanel(
                                          condition = "input.global_fit == false",
                                          fluidRow(
                                            column(1,
                                                   checkboxInput(inputId = "override_age", "", value = FALSE)),
                                            column(width = 5,
                                                   numericInput(inputId = "age", "Age (a)", value = 1000, min = 0),
                                                   title = "The age (a) of the sample."
                                            ),
                                            conditionalPanel(condition = "input.override_mu == true",
                                                             column(width = 4,
                                                                    numericInput(inputId = "mu", "\\( \\mu \\)",
                                                                                 value = 0.9, min = 0),
                                                                    title = "The light attenuation coefficient."
                                                             )
                                            )
                                          )
                                        ),
                                        fluidRow(
                                          column(1,
                                                 checkboxInput(inputId = "override_sigmaphi", "", value = TRUE)),
                                          column(10,
                                                 fluidRow(
                                                   column(width = 6,
                                                          numericInput(inputId = "sigmaphi_base", "\\( \\overline{\\sigma\\varphi_0} \\) (base)", value = 5.0, step = 0.1)
                                                   ),
                                                   column(width = 6,
                                                          numericInput(inputId = "sigmaphi_exp", "\\( \\overline{\\sigma\\varphi_0} \\) (exponent)",
                                                                       value = -10, max = 0, step = 1)
                                                   )
                                                 ),
                                                 title = "The charge detrapping rate."
                                          )
                                        ))
                               ),

                               tabPanel("Dose rate",
                                        RLumShiny:::section("Dose rate",
                                        checkboxInput("doserate", "Consider dose rate", FALSE),
                                        helpText(HTML(paste(
                                          "This will fit eq. 12 in Sohbati et al. (2012b) to the data. <b>Note</b>, however,",
                                          "that here the dose rate is assumed constant, i.e., it is independent of sample depth."
                                        ))),
                                        withMathJax(),
                                        helpText("$$L(x) = \\frac{\\overline{\\sigma\\varphi _0}e^{-\\mu x}e^{-t[\\overline{\\sigma\\varphi _0}e^{-\\mu x} + \\frac{\\dot{D}}{D_0}]}+ \\frac{\\dot{D}}{D_0}}
{\\overline{\\sigma\\varphi _0}e^{-\\mu x} + \\frac{\\dot{D}}{D_0}}$$"),
                                        conditionalPanel(condition = "input.doserate == true",
                                                         numericInput("ddot", "Environmental dose rate, \\(\\dot{D}\\) (Gy/ka)",
                                                                      value = 1.5, min = 0, step = 0.01),
                                                         numericInput("d0", "Characteristic saturation dose, \\(D_0\\) (Gy)",
                                                                      value = 40, min = 0, step = 1)
                                        ),
                                        hr(),
                                        helpText(HTML(paste(tags$b("Reference:"), "Sohbati, R., Jain, M., Murray, A.S., 2012b. Surface exposure dating of non-terrestial bodies using optically stimulated luminescence: A new method. Icarus 221, 160-166.")))
                               )
                               ),

                               tabPanel("Plot",
                                        RLumShiny:::section("Plot elements",
                                        textInput(inputId = "main",
                                                  label = "Title",
                                                  value = "OSL Surface Exposure Dating"),

                                        fluidRow(
                                          column(width = 6,
                                                 RLumShiny:::pointSymbolChooser(inputId = "pch",
                                                                    label = "Datapoint style",
                                                                    selected = "21")
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
                                                             selected = "red",
                                                             choices = list("Black" = "black",
                                                                            "Grey" = "grey50",
                                                                            "Red" = "red", #"#b22222",
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

                                        fluidRow(
                                          column(width = 6,
                                                 RLumShiny:::lineTypeChooser(inputId = "lty",
                                                                             label = "Fitting line style",
                                                                             selected = 1)
                                          ),
                                          column(width = 6,
                                                 RLumShiny:::lineWidthChooser(inputId = "lwd")
                                          )
                                        ),

                                        fluidRow(
                                          column(width = 6,
                                                 selectInput(inputId = "line_col", label = "Fitting line color",
                                                             selected = "default",
                                                             choices = list("Default" = "default",
                                                                            "Black" = "black",
                                                                            "Grey" = "grey50",
                                                                            "Red" = "#b22222",
                                                                            "Green" = "#6E8B3D",
                                                                            "Blue" = "#428bca",
                                                                            "Custom" = "custom"))
                                          ),
                                          column(width = 6,
                                                 # show only if custom color is desired
                                                 conditionalPanel(condition = "input.line_col == 'custom'",
                                                                  HTML("Choose a color<br>"),
                                                                  jscolorInput(inputId = "jscol2"))
                                          )
                                        ),

                                        fluidRow(
                                          column(width = 6,
                                                 checkboxInput(inputId = "legend",
                                                               label = "Show legend",
                                                               value = TRUE)
                                          ),
                                          column(width = 6,
                                                 checkboxInput(inputId = "error_bars",
                                                               label = "Show error bars",
                                                               value = TRUE),
                                                 title = "Show or hide error bars (only applies if errors are provided)."
                                          )
                                        )),

                                        RLumShiny:::section("Scaling",
                                        sliderInput(inputId = "cex",
                                                    label = "Scaling factor",
                                                    min = 0.5, max = 2,
                                                    value = 1.1, step = 0.1)
                                        )
                               ),##EndOf::Tab_3

                               # Tab 4: modify axis parameters
                               tabPanel("Axis",
                                        RLumShiny:::section("X-axis",
                                        checkboxInput(inputId = "logx",
                                                      label = "Logarithmic x-axis",
                                                      value = FALSE),
                                        textInput(inputId = "xlab",
                                                  label = "Label x-axis",
                                                  value = "Depth (mm)"),
                                        # inject sliderInput from Server.R
                                        sliderInput(inputId = "xlim", "X-axis limits", min = -15, max = 20,
                                                    value = c(-0, 10), step = 0.1)
                                        ),

                                        RLumShiny:::section("Y-axis",
                                        checkboxInput(inputId = "logy",
                                                      label = "Logarithmic y-axis",
                                                      value = FALSE),
                                        textInput(inputId = "ylab",
                                                  label = "Label y-axis (left)",
                                                  value = "OSL intensity (Ln/Tn)"),
                                        sliderInput(inputId = "ylim", "Y-axis limits", min = -1, max = 2,
                                                    value = c(-0.1, 1.1), step = 0.1),
                                        checkboxInput(inputId = "coord_flip",
                                                      label = "Flip the coordinate system",
                                                      value = FALSE)
                                        )
                               ),##EndOf::Tab_4

                               RLumShiny:::exportTab("export", filename = "surfaceexposure"),
                               RLumShiny:::aboutTab("about", "surfaceExposure")
                   )##EndOf::tabsetPanel
      ),##EndOf::sidebarPanel

      # 3 - output panel
      mainPanel(width = 8,
                # insert css code inside <head></head> of the generated HTML file:
                # allow open dropdown menus to reach over the container
                tags$head(tags$style(type="text/css",".tab-content {overflow: visible;}")),
                tags$head(includeCSS("www/style.css")),
                # divide output in separate tabs via tabsetPanel
                tabsetPanel(
                  tabPanel("Plot",
                           plotOutput(outputId = "main_plot", height = "500px"),
                           htmlOutput(outputId = "console")),
                  tabPanel("R code", verbatimTextOutput("plotCode"))
                )###EndOf::tabsetPanel
      )##EndOf::mainPanel
    ),##EndOf::sideBarLayout
    bookmarkButton()
  )##EndOf::fluidPage
}
