## UI.R
function(request) {
  fluidPage(
    titlePanel(NULL, windowTitle = "RLumShiny - SAR CWOSL"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 5,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Import",
                               # Tab 1: Data input
                               RLumShiny:::importTab("import",
                                                     "XSYG file (.xsyg)",
                                                     "application/xml, .xsyg"),

                               tabPanel("Method",
                                        div(align = "center", h5("Input data preprocessing")),
                                        sliderInput(inputId = "signal_integral",
                                                    "Signal integral",
                                                    value = c(1, 5),
                                                    min = 1,
                                                    max = 1000,
                                                    step = 1,
                                                    dragRange = TRUE),
                                        sliderInput(inputId = "background_integral",
                                                    "Background integral",
                                                    value = c(900, 1000),
                                                    min = 1,
                                                    max = 1000,
                                                    step = 1,
                                                    dragRange = TRUE)
                               ),

                               tabPanel("Plot",
                                        div(align = "center", h5("Plot elements")),
                                        textInput(inputId = "main",
                                                  label = "Title",
                                                  value = "Growth Curve"),

                                        br(),
                                        div(align = "center", h5("Axes")),

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

                               RLumShiny:::exportTab("export", filename = "sarCWOSL"),
                               RLumShiny:::aboutTab("about", "sarCWOSL")
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
                    tabPanel("R code", verbatimTextOutput("plotCode"))
                  )
                )
      )##EndOf::mainPanel
    ),##EndOf::sideBarLayout
    bookmarkButton()
  )##EndOf::fluidPage
}
