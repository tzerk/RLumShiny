## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    data <- LxTxData
  }

  values <- reactiveValues(data_primary = data,
                           args.fit = NULL,
                           args.plot = NULL,
                           fit = NULL,
                           results = NULL)

  session$onSessionEnded(function() {
    stopApp()
  })

  # check and read in file (DATA SET 1)
  observeEvent(input$file, {
    inFile <- input$file
    if(is.null(inFile))
      return(NULL) # if no file was uploaded return NULL

    values$data_primary <- fread(file = inFile$datapath, data.table = FALSE) # inFile[1] contains filepath
    if (ncol(values$data_primary) > 4)
      values$data_primary <- values$data_primary[, 1:4]
  })

  observeEvent(input$table_in_primary, {
    res <- rhandsontable_workaround(input$table_in_primary, values)
    if (!is.null(res))
      values$data_primary <- res
  })

  observe({
    values$args.fit <- list(
      # fit_DoseResponseCurve arguments
      object = values$data_primary,
      fit.method = input$fit_method,
      mode = input$mode,
      fit.force_through_origin = input$force_through_origin,
      fit.weights = input$fit_weights,
      verbose = FALSE)

    values$args.plot <- list(
      # plot_DoseResponseCurve arguments
      object = NULL, # will be set further down
      plot_extended = input$extended,
      density_rug = input$density_rug,
      box = input$box,
      legend = input$showlegend,
      legend.pos = input$legend_pos,
      verbose = FALSE,
      # generic plot arguments
      main = input$main,
      xlab = input$xlab,
      ylab = input$ylab,
      log = paste0("", ifelse(input$logx, "x", ""), ifelse(input$logy, "y", "")),
      cex = input$cex
    )
  })

  observe({
    values$data_primary
    res <- tryNotify(do.call(fit_DoseResponseCurve, values$args.fit))
    if (inherits(res, "RLum.Results"))
      values$fit <- res
  })

  output$main_plot <- renderPlot({
    ## remove existing notifications
    removeNotification(id = "notification")

    ## modify the object to plot_DoseResponseCurve() to be the fitted object
    args <- values$args.plot
    args$object <- values$fit
    values$results <- do.call(plot_DoseResponseCurve, args)
  })

  output$table_in_primary <- renderRHandsontable({
    rhandsontable(values$data_primary,
                  height = 300,
                  colHeaders = c("Dose", "LxTx", "LxTx.Error", "TnTx"),
                  rowHeaders = NULL)
  })

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 1,
                              list(name = "fit_DoseResponseCurve",
                                   arg1 = "data",
                                   args = values$args.fit,
                                   rets = "fit"),
                              list(name = "plot_DoseResponseCurve",
                                   arg1 = "fit",
                                   args = values$args.plot)
                              )

    output$plotCode <- renderText(code.output)

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "plot_DoseResponseCurve",
               args = values$args)
  })

}##EndOf::function(input, output)
