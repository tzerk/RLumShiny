## UI.R
function(request) {
  fluidPage(
    titlePanel("Convert", windowTitle = "RLumShiny - Convert"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 5,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Import",
                               # Tab 1: Data input
                               RLumShiny:::importTab("import",
                                                     "BIN(X) file (.bin, .binx)",
                                                     "application/octet-stream, .bin, .binx"
                                                     ),
                               tabPanel("Curve Selection",
                                        # dynamic elements depending on input file
                                        fluidRow(
                                          column(width = 6,
                                                 uiOutput("positions")

                                          ),
                                          column(width = 6,
                                                 uiOutput("curveTypes")
                                          )
                                        ),

                                        div(align = "center", h5("(De)select individual curves")),
                                        checkboxGroupInput("curves", "Curves")
                               ),##EndOf::Tab_2

                               tabPanel("Export",
                                        selectInput("targetFile", label = "Export to...",
                                                    choices = list("BINX" = "binx",
                                                                   "CSV" = "csv")),
                                        downloadButton("export",
                                                       label = "Download file",
                                                       class = "btn btn-success")
                                        )
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
                  uiOutput("positionTabs")
                )
      )##EndOf::mainPanel
    ),##EndOf::sideBarLayout
    bookmarkButton()
  )##EndOf::fluidPage
}
