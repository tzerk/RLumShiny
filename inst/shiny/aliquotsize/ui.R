## UI.R
function(request) {
  fluidPage(
    titlePanel("Aliquot Size", windowTitle = "RLumShiny - Aliquot Size"),
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
                                        div(align = "center", h5("Data input")),
                                        div(align = "left",
                                            sliderInput(inputId = "grain_size",
                                                        label = "Range of grain sizes (microns)",
                                                        min = 0.001, max = 1000,
                                                        value = c(100, 200),
                                                        step = 1),
                                            title = "Minimum and maximum grain size."),
                                        fluidRow(
                                            column(width = 6,
                                                   numericInput(inputId = "sample_diameter",
                                                                label = "Sample diameter (mm)",
                                                                value = 3.6,
                                                                min = 0.1,
                                                                step = 0.1),
                                                   title = "Diameter of the targeted area on the sample carrier."
                                                   ),
                                            column(width = 6,
                                                   numericInput(inputId = "sample_carrier_diameter",
                                                                label = "Sample carrier diameter (mm)",
                                                                value = 9.8,
                                                                min = 1,
                                                                max = 20,
                                                                step = 0.1),
                                                   title = "Diameter of the sample carrier."
                                                   )
                                        ),

                                        # informational text
                                        div(align = "center", h5("Computation mode")),
                                        radioButtons(inputId = "mode",
                                                     label = "",
                                                     selected = "pd",
                                                     choices = c("Provide the packing density to estimate the grain count" = "pd",
                                                                 "Provide the grain count to estimate the packing density (no plot produced)" = "gc")
                                                     ),
                                        fluidRow(
                                            column(width = 6,
                                                   conditionalPanel("input.mode == 'pd'",
                                                                    sliderInput(inputId = "packing_density",
                                                                                label = "Packing density",
                                                                                value = 0.65,
                                                                                min = 0.05,
                                                                                max = 0.95,
                                                                                step = 0.05),
                                                                    title = "Empirical value for the mean packing density."
                                                                    ),
                                                   conditionalPanel("input.mode == 'pd'",
                                                                    numericInput(inputId = "MC_iter",
                                                                                 label = "Monte Carlo iterations",
                                                                                 value = 1000,
                                                                                 min = 250,
                                                                                 max = 10000,
                                                                                 step = 250),
                                                                    title = "Number of Monte Carlo iterations for estimating the amount of grains on the sample carrier."
                                                                    ),
                                                   conditionalPanel("input.mode == 'gc'",
                                                                    # TODO: call updateSlider in Server.R to update max range
                                                                    numericInput(inputId = "grains_counted",
                                                                                 label = "Grains counted",
                                                                                 value = 100,
                                                                                 min = 1,
                                                                                 max = 10000,
                                                                                 step = 1),
                                                                    title = "Number of grains counted on a sample carrier."
                                                                    )
                                                   )
                                        )

                               ),##EndOf::Tab_1

                               # Tab 2: Plot
                               tabPanel("Plot",
                                        div(align = "center", h5("Main elements")),

                                        textInput(inputId = "main",
                                                  label = "Title",
                                                  value = "Monte Carlo Simulation"),

                                        textInput(inputId = "xlab",
                                                  label = "Label x-axis",
                                                  value = "Amount of grains on aliquot"),

                                        fluidRow(
                                          column(width = 6,
                                                 selectInput(inputId = "color", label = "Histogram color",
                                                             choices = list("Grey" = "grey90",
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

                                        fluidRow(
                                          column(width = 6,
                                                 selectInput(inputId = "line_col", label = "KDE line color",
                                                             choices = list("Black" = "black",
                                                                            "Grey" = "grey90",
                                                                            "Red" = "#b22222",
                                                                            "Green" = "#6E8B3D",
                                                                            "Blue" = "#428bca",
                                                                            "None" = NA,
                                                                            "Custom" = "custom"))
                                          ),
                                          column(width = 6,
                                                 # show only if custom color is desired
                                                 conditionalPanel(condition = "input.line_col == 'custom'",
                                                                  HTML("Choose a color<br>"),
                                                                  jscolorInput(inputId = "jscol2"))
                                          )
                                        ),

                                        div(align = "center", h5("Additional elements")),
                                        fluidRow(
                                            column(width = 6,
                                                   checkboxInput(inputId = "rug",
                                                                 label = "Show rug",
                                                                 value = TRUE),
                                                   ),
                                            column(width = 6,
                                                   checkboxInput(inputId = "boxplot",
                                                                 label = "Show boxplot",
                                                                 value = TRUE),
                                                   )
                                        ),
                                        fluidRow(
                                            column(width = 6,
                                                   checkboxInput(inputId = "summary",
                                                                 label = "Show summary statistics",
                                                                 value = TRUE),
                                                   ),
                                            column(width = 6,
                                                   checkboxInput(inputId = "legend",
                                                                 label = "Show legend",
                                                                 value = TRUE)
                                                   )
                                        ),

                                        br(),
                                        div(align = "center", h5("Scaling")),
                                        sliderInput(inputId = "cex",
                                                    label = "Scaling factor",
                                                    min = 0.5, max = 2,
                                                    value = 1.0, step = 0.1)
                               ),##EndOf::Tab_2

                               RLumShiny:::exportTab("export", filename = "aliquot size"),
                               RLumShiny:::aboutTab("about", "aliquotsize")
                   )##EndOf::tabsetPanel
      ),##EndOf::sidebarPanel

      # 3 - output panel
      mainPanel(width = 7,
                # insert css code inside <head></head> of the generated HTML file:
                # allow open dropdown menus to reach over the container
                tags$head(tags$style(type="text/css", ".tab-content {overflow: visible;}")),
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
