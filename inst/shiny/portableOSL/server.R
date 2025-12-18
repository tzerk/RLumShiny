## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    data <- merge_RLum(ExampleData.portableOSL)
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

    ## read psl file
    if (tools::file_ext(inFile$name) == "psl") {
      # import the file as RLum.Analysis object
      values$data_primary <- read_PSL2R(inFile$datapath,
                                        fastForward = TRUE,
                                        verbose = FALSE)
    }
  })

  observe({
    values$args <- list(
      # analyse_portableOSL arguments
      object = values$data_primary,
      signal.integral = input$signal_integral,
      invert = input$invert,
      normalise = input$normalise,
      mode = input$mode,
      verbose = FALSE,
      # generic plot arguments
      main = input$main,
      type = input$type,
      pch = rep(ifelse(input$pch == "custom", input$custompch, as.numeric(input$pch)), 6),
      cex = input$cex,
      xlab = input$xlab,
      ylab = input$ylab,
      grid = input$grid,
      legend = input$legend,
      contour = input$nlevels > 0,
      contour_nlevels = input$nlevels,
      contour_col = ifelse(input$contour_col == "custom", input$jscol, input$contour_col)
    )

    ## set the maximum signal_integral allowed
    max.channels <- min(sapply(get_RLum(values$data_primary,
                                        recordType = c("OSL", "IRSL")),
                               length))
    updateSliderInput(session, "signal_integral",
                      max = max.channels)
  })

  output$main_plot <- renderPlot({
    ## remove existing notifications
    removeNotification(id = "notification")

    res <- RLumShiny:::tryNotify(do.call(analyse_portableOSL, values$args))
    if (inherits(res, "RLum.Results"))
      values$results <- res
  })

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 1,
                              list(name = "analyse_portableOSL",
                                   arg1 = "data",
                                   args = values$args))

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "analyse_portableOSL", args = values$args)
  })

}##EndOf::function(input, output)
