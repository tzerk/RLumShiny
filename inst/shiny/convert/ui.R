## UI.R
function(request) {
  fluidPage(
    titlePanel(NULL, windowTitle = "RLumShiny - Fast Ratio"),
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
                                                  label = strong("Measurement file"),
                                                  accept="application/octet-stream, .bin, .binx"),
                                        # import
                                        actionButton(inputId = "import", label = "Import", class = "btn btn-success"),
                                        tags$hr(),
                                        # dynamic elements depending on input file
                                        fluidRow(
                                          column(width = 6,
                                                 uiOutput("positions")
                                                 
                                          ),
                                          column(width = 6,
                                                 uiOutput("types")
                                          )
                                        )
                               ),##EndOf::Tab_1
                               
                               tabPanel("Method",
                                        div(align = "center", h5("Input data preprocessing"))
                                        
                               )##EndOf::Tab_4
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
                    tabPanel("Preview", 
                             plotOutput(outputId = "main_plot", height = "500px"),
                             htmlOutput(outputId = "results")
                             )
                  )
                )
      )##EndOf::mainPanel
    ),##EndOf::sideBarLayout
    bookmarkButton()
  )##EndOf::fluidPage
}