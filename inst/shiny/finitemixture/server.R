## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    data <- ExampleData.DeValues$CA1
  }
  values <- reactiveValues(data_primary = data,
                           args = NULL,
                           results = NULL)

  session$onSessionEnded(function() {
    stopApp()
  })

  # check and read in file (DATA SET 1)
  observeEvent(input$file, {
    inFile<- input$file

    if(is.null(inFile))
      return(NULL) # if no file was uploaded return NULL

    values$data_primary <- fread(file = inFile$datapath, data.table = FALSE) # inFile[1] contains filepath
    if (ncol(values$data_primary) > 2)
      values$data_primary <- values$data_primary[, 1:2]
  })

  observeEvent(input$table_in_primary, {
    res <- RLumShiny:::rhandsontable_workaround(input$table_in_primary)
    if (!is.null(res))
      values$data_primary <- res
  })

  n.components.range <- reactive({
    n.components <- input$n_components
    ## don't let the slider limits overlap, as calc_FiniteMixture() throws an
    ## error if only one component is specified
    if (diff(n.components) == 0) {
      if (n.components[2] == 10)
        n.components[1] <- 9
      else
        n.components[2] <- n.components[2] + 1
      n.components
      updateSliderInput(session, "n_components", value = n.components)
    }
    n.components[1]:n.components[2]
  })

  observe({
    values$args <- list(
      # calc_FiniteMixture arguments
      data = values$data_primary,
      sigmab = max(input$sigmab, 0.01),
      n.components = n.components.range(),
      pdf.weight = input$pdf_weight,
      pdf.sigma = if (input$pdf_sigma) "sigma" else "se",
      pdf.colors = input$pdf_colors,
      plot.proportions = input$plot_proportions,
      plot.criteria = input$plot_criteria,
      verbose = FALSE,
      # generic plot arguments
      main = input$main,
      main.densities = input$main_densities,
      main.proportions = input$main_proportions,
      main.criteria = input$main_criteria,
      cex = input$cex
    )
  })

  output$main_plot <- renderPlot({
    res <- RLumShiny:::tryNotify(do.call(calc_FiniteMixture, values$args))
    if (inherits(res, "RLum.Results")) {
      ## remove existing notifications
      removeNotification(id = "notification")
      values$results <- res
    }
  })

  output$table_in_primary <- renderRHandsontable({
    rhandsontable(values$data_primary,
                  height = 300,
                  colHeaders = c("Dose", "Error"),
                  rowHeaders = NULL)
  })

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 1,
                              list(name = "calc_FiniteMixture",
                                   arg1 = "data",
                                   args = values$args))

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "calc_FiniteMixture", args = values$args)
  })

}##EndOf::function(input, output)
