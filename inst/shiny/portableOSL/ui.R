## UI.R
function(request) {
  fluidPage(
    titlePanel("Portable OSL", windowTitle = "RLumShiny - Portable OSL"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 5,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Import",
                               RLumShiny:::importTab("import",
                                                     label = "Measurement file (.psl)",
                                                     accept = "text/plain, .psl"),

                               tabPanel("Method",
                                        div(align = "center", h5("Input data preprocessing")),
                                        sliderInput(inputId = "signal_integral",
                                                    "Signal integral",
                                                    value = c(1, 5),
                                                    min = 1,
                                                    max = 1000,
                                                    step = 1,
                                                    dragRange = TRUE),

                                        radioButtons(inputId = "mode",
                                                     label = "Computation mode",
                                                     selected = "profile",
                                                     choices = c(profile = "profile",
                                                                 surface = "surface")
                                                     ),
                                        checkboxInput(inputId = "normalise",
                                                      "Normalise",
                                                      value = FALSE)
                               ),

                               tabPanel("Plot",
                                        div(align = "center", h5("Plot elements")),
                                        textInput(inputId = "main",
                                                  label = "Title",
                                                  value = "Portable OSL"),

                                        conditionalPanel(condition = "input.mode == 'profile'",
                                                         radioButtons("type", "Type", selected = "b", inline = TRUE,
                                                                      choices = c("Line+Points" = "b",
                                                                                  "Line" = "l",
                                                                                  "Points" = "p")
                                                                      ),
                                                         fluidRow(
                                                             column(width = 6,
                                                                    RLumShiny:::pointSymbolChooser(inputId = "pch",
                                                                                       label = "Point style",
                                                                                       selected = "16")
                                                                    ),
                                                             column(width = 6,
                                                                    # show only if custom symbol is desired
                                                                    conditionalPanel(condition = "input.pch == 'custom'",
                                                                                     RLumShiny:::customSymbolChooser(inputId = "custompch")
                                                                                     )
                                                                    )
                                                         ),

                                                         checkboxInput(inputId = "grid",
                                                                       label = "Show grid",
                                                                       value = TRUE),
                                                         ),

                                        conditionalPanel(condition = "input.mode == 'surface'",
                                                         sliderInput(inputId = "nlevels",
                                                                     label = "Number of contour levels",
                                                                     min = 0, max = 20,
                                                                     value = 2,
                                                                     step = 1
                                                                     ),

                                                         fluidRow(
                                                             column(width = 6,
                                                                    selectInput(inputId = "contour_col",
                                                                                label = "Contour color",
                                                                                choices = list("Grey" = "grey50",
                                                                                               "Red" = "#b22222",
                                                                                               "Green" = "#6E8B3D",
                                                                                               "Blue" = "#428bca",
                                                                                               "Custom" = "custom"))
                                                                    ),
                                                             column(width = 6,
                                                                    # show only if custom color is desired
                                                                    conditionalPanel(condition = "input.contour_col == 'custom'",
                                                                                     HTML("Choose a color<br>"),
                                                                                     jscolorInput(inputId = "jscol"))
                                                                    )
                                                         )
                                        ),

                                        div(align = "center", h5("Axis")),
                                        conditionalPanel(condition = "input.mode == 'surface'",
                                                         textInput(inputId = "xlab",
                                                                   label = "Label x-axis",
                                                                   value = "t (s)"),
                                                         ),
                                        textInput(inputId = "ylab",
                                                  label = "Label y-axis",
                                                  value = "Depth [m]"),
                                        checkboxInput(inputId = "invert",
                                                      "Invert axis",
                                                      value = FALSE),
                                        conditionalPanel(condition = "input.mode == 'surface'",
                                                         checkboxInput(inputId = "legend",
                                                                       label = "Show legend",
                                                                       value = TRUE)
                                                         ),

                                        div(align = "center", h5("Scaling")),
                                        sliderInput(inputId = "cex",
                                                    label = "Scaling factor",
                                                    min = 0.5, max = 2,
                                                    value = 1.0, step = 0.1)

                               ),##EndOf::Tab_3
                               RLumShiny:::exportTab("export", filename = "portableOSL"),
                               RLumShiny:::aboutTab("about", "portableOSL")
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
