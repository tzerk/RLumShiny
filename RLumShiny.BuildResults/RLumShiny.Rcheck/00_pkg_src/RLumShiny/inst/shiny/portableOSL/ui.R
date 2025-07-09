## UI.R
function(request) {
  fluidPage(
    titlePanel(NULL, windowTitle = "RLumShiny - Portable OSL"),
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
                                        fileInput(inputId = "file",
                                                  label = strong("Primary data set"),
                                                  placeholder = "A CSV file with two columns (Time and Counts)",
                                                  accept="text/plain, .csv, text/csv"),
                                        # rhandsontable input/output
                                        fluidRow(
                                          column(width = 6,
                                                 rHandsontableOutput(outputId = "table_in_primary")
                                          )
                                        )

                               ),##EndOf::Tab_1

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
                                                                    selectInput(inputId = "pch",
                                                                                label = "Point style",
                                                                                selected = "16",
                                                                                choices = c("Square"= "0",
                                                                                            "Circle"="1",
                                                                                            "Triangle point up"="2",
                                                                                            "Plus"="3",
                                                                                            "Cross"="4",
                                                                                            "Diamond"="5",
                                                                                            "Triangle point down"="6",
                                                                                            "Square cross"="7",
                                                                                            "Star"="8",
                                                                                            "Diamond plus"="9",
                                                                                            "Circle plus"="10",
                                                                                            "Triangles up and down"="11",
                                                                                            "Square plus"="12",
                                                                                            "Circle cross"="13",
                                                                                            "Square and Triangle down"="14",
                                                                                            "filled Square"="15",
                                                                                            "filled Circle"="16",
                                                                                            "filled Triangle point up"="17",
                                                                                            "filled Diamond"="18",
                                                                                            "solid Circle"="19",
                                                                                            "Bullet (smaller Circle)"="20",
                                                                                            "Custom"="custom"))
                                                                    ),
                                                             column(width = 6,
                                                                    # show only if custom symbol is desired
                                                                    conditionalPanel(condition = "input.pch == 'custom'",
                                                                                     textInput(inputId = "custompch",
                                                                                               label = "Insert character",
                                                                                               value = "?"))
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
