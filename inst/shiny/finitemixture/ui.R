## UI.R
function(request) {
  fluidPage(
    titlePanel("Finite Mixture", windowTitle = "RLumShiny - Finite Mixture"),
    sidebarLayout(
      # 2- width = 5 -> refers to twitters bootstrap grid system
      # where the the maximum width is 12 that is to be shared between all
      # elements
      sidebarPanel(width = 5,
                   # include a tabs in the input panel for easier navigation
                   tabsetPanel(id = "tabs", type = "pill", selected = "Import",
                               # Tab 1: Data input
                               RLumShiny:::importTab("import",
                                                     "CSV file with two columns (De and De error)",
                                                     "text/csv, .csv",
                                                     callback = function() {
                                                       # rhandsontable input/output
                                                       fluidRow(
                                                           column(width = 6,
                                                                  rHandsontableOutput(outputId = "table_in_primary")
                                                                  )
                                                       )
                                                     }
                               ), ## EndOf::Tab_1

                               tabPanel("Method",
                                        div(align = "center", h5("Model parameters")),
                                        div(align = "left",
                                            sliderInput(inputId = "sigmab",
                                                        HTML("Spread in De values (&sigma;<sub>b</sub>)"),
                                                        value = 0.2,
                                                        min = 0,
                                                        max = 1,
                                                        step = 0.01),
                                            title = "Expected overdispersion in the data should the sample be well-bleached expressed as a fraction."),

                                        div(align = "left",
                                            sliderInput(inputId = "n_components",
                                                        label = "Number of components",
                                                        value = c(2, 3),
                                                        min = 2,
                                                        max = 10,
                                                        step = 1,
                                                        dragRange = FALSE),
                                            title = "Number of components to be fitted.")
                                        ),

                               tabPanel("Plot",
                                        div(align = "center", h5("Plot elements")),
                                        textInput(inputId = "main",
                                                  label = "Title",
                                                  value = "Finite Mixture Model"),

                                        fluidRow(
                                          column(width = 6,
                                                 checkboxInput(inputId = "plot_proportions",
                                                               label = "Plot proportion of components",
                                                               value = TRUE)
                                                 ),
                                          column(width = 6,
                                                 checkboxInput(inputId = "plot_criteria",
                                                               label = "Plot statistical criteria",
                                                               value = TRUE)
                                                 )
                                        ),

                                        radioButtons(inputId = "pdf_colors",
                                                     label = "Area shading",
                                                     selected = "colors",
                                                     inline = TRUE,
                                                     choices = c("Colour" = "colors",
                                                                 "Grayscale" = "gray",
                                                                 "None" = "none")
                                                     ),

                                        div(align = "center", h5("Density plots")),

                                        div(align = "left",
                                            checkboxInput(inputId = "pdf_weight",
                                                          label = "Use component proportions as weights",
                                                          value = TRUE),
                                            title = "Weight the probability density functions by the components proportion."),

                                        div(align = "left",
                                            checkboxInput(inputId = "pdf_sigma",
                                                          label = "Use common standard deviation",
                                                          value = TRUE),
                                            title = "The components normal distributions can be plotted using a common standard deviation (i.e. `sigmab`) or using the standard error of each component."),

                                        div(align = "center", h5("Scaling")),
                                        sliderInput(inputId = "cex",
                                                    label = "Scaling factor",
                                                    min = 0.5, max = 2,
                                                    value = 1.0, step = 0.1)

                               ),##EndOf::Tab_3

                               tabPanel("Subplot labels",

                                        div(align = "center", h5("Density plots")),

                                        textInput(inputId = "main_densities",
                                                  label = "Densities label",
                                                  value = "Normal distributions"),

                                        conditionalPanel("input.plot_proportions == true",
                                                         textInput(inputId = "main_proportions",
                                                                   label = "Barplot label",
                                                                   value = "Proportion of components")
                                                         ),

                                        conditionalPanel("input.plot_criteria == true",
                                                         textInput(inputId = "main_criteria",
                                                                   label = "Line plot label",
                                                                   value = "Statistical criteria")
                                                         )

                               ),##EndOf::Tab_4

                               RLumShiny:::exportTab("export", filename = "finitemixture"),
                               RLumShiny:::aboutTab("about", "finitemixture")
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
                             plotOutput(outputId = "main_plot", height = "600px"),
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
