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
  })

  observeEvent(input$table_in_primary, {

    # Workaround for rhandsontable issue #138
    # https://github.com/jrowen/rhandsontable/issues/138
    # See detailed explanation in abanico application
    df_tmp <- input$table_in_primary
    row_names <-  as.list(as.character(seq_len(length(df_tmp$data))))
    df_tmp$params$rRowHeaders <- row_names
    df_tmp$params$rowHeaders <- row_names
    df_tmp$params$rDataDim <- as.list(c(length(row_names),
                                        length(df_tmp$params$columns)))
    if (df_tmp$changes$event == "afterRemoveRow")
      df_tmp$changes$event <- "afterChange"

    if (!is.null(hot_to_r(df_tmp)))
      values$data_primary <- hot_to_r(df_tmp)
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
    values$fit <- do.call(fit_DoseResponseCurve, values$args.fit)
  })

  output$main_plot <- renderPlot({
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
    args <- values$args.plot
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_input = 1,
                              fun = "plot_DoseResponseCurve(object = data,",
                              args = args)

    output$plotCode <- renderText(code.output)

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "plot_DoseResponseCurve",
               args = values$args)
  })

}##EndOf::function(input, output)
