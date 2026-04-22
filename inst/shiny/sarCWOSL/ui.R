## UI.R
function(request) {
  fluidPage(
    titlePanel("SAR CWOSL", windowTitle = "RLumShiny - SAR CWOSL"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 5,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Import",
                               # Tab 1: Data input
                               RLumShiny:::importTab("import",
                                                     "XSYG file (.xsyg) or BIN/BINX (.bin/.binx)",
                                                     "application/xml, .xsyg, application/octet-stream, .bin, .binx",
                                                     callback = function() {

                                   list(
                                       div(align = "center", h5("Curve selection")),
                                       fluidRow(
                                           column(width = 6,
                                                  uiOutput("positions")

                                           ),
                                           column(width = 6,
                                                  uiOutput("recordTypes")
                                           )
                                       ),

                                       div(align = "center", h5("(De)select individual curves")),
                                       uiOutput("curves")
                                   )
                               }),

                               tabPanel("Method",
                                        div(align = "center", h5("Input data preprocessing")),
                                        sliderInput(inputId = "signal_integral",
                                                    "Signal integral",
                                                    value = c(1, 5),
                                                    min = 1,
                                                    max = 1000,
                                                    step = 1,
                                                    dragRange = TRUE),
                                        checkboxInput(inputId = "sub_bg_integral",
                                                      label = "Subtract the background integral",
                                                      value = TRUE),
                                        conditionalPanel(condition = "input.sub_bg_integral == true",
                                            sliderInput(inputId = "background_integral",
                                                    "Background integral",
                                                    value = c(900, 1000),
                                                    min = 1,
                                                    max = 1000,
                                                    step = 1,
                                                    dragRange = TRUE)
                                        ),
                                        radioButtons(inputId = "mode",
                                                     label = "Mode",
                                                     selected = "interpolation",
                                                     choices = c("interpolation" = "interpolation",
                                                                 "extrapolation" = "extrapolation")
                                                     ),
                                        selectInput(inputId = "fit_method",
                                                    "Fit method",
                                                    selected = "EXP",
                                                    choices = list("EXP" = "EXP",
                                                                   "LIN" = "LIN",
                                                                   "QDR" = "QDR",
                                                                   "GOK" = "GOK",
                                                                   "EXP OR LIN" = "EXP OR LIN",
                                                                   "EXP+LIN" = "EXP+LIN",
                                                                   "EXP+EXP" = "EXP+EXP",
                                                                   "OTOR" = "OTOR"))
                               ),

                               tabPanel("Plot",
                                        div(align = "center", h5("Plot elements")),
                                        textInput(inputId = "main",
                                                  label = "Title",
                                                  value = ""),

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
                                        div(align = "center", h5("Dose response curve")),
                                        fluidRow(
                                            column(width = 6,
                                                   checkboxInput(inputId = "showlegend",
                                                                 label = "Show legend",
                                                                 value = TRUE)
                                                   ),
                                            column(width = 6,
                                                   checkboxInput(inputId = "showrug",
                                                                 label = "Show rug",
                                                                 value = TRUE)
                                                   )
                                        ),
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
