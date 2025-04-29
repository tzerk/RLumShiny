## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    data <- ExampleData.Fading$equivalentDose.data$IR50
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
  })

  observe({
    values$args <- list(
      # calc_Huntley2006 arguments
      data = values$data_primary,
      rhop = as.numeric(c(input$rhop, input$rhop_error)),
      ddot = as.numeric(c(input$ddot, input$ddot_error)),
      readerDdot = as.numeric(c(input$reader_ddot, input$reader_ddot_error)),
      normalise = input$normalise,
      fit.method = input$fit_method,
      n.MC = input$n_MC,
      verbose = FALSE,
      # fit_DoseResposeCurve arguments
      mode = input$mode,
      fit.bounds = input$fit_bounds,
      fit.force_through_origin = input$fit_force_through_origin,
      # generic plot arguments
      main = input$main,
      type = input$type,
      pch = rep(ifelse(input$pch == "custom", input$custompch, as.numeric(input$pch)), 6),
      cex = input$cex,
      xlab = input$xlab,
      ylab = ifelse(input$normalise, paste("normalised", input$ylab), input$ylab),
      summary = input$summary,
      plot_all_DRC = FALSE
    )
  })

  output$main_plot <- renderPlot({
    showNotification(id = "progress", duration = NULL, "This may take a while")
    set.seed(1)
    values$results <- do.call(calc_Huntley2006, values$args)
    removeNotification(id = "progress")
  })

  output$table_in_primary <- renderRHandsontable({
    rhandsontable(values$data_primary,
                  height = 300,
                  colHeaders = c("Dose", "LxTx", "LxTx.error"),
                  rowHeaders = NULL)
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
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode", n_input = 1,
                              fun = "calc_Huntley2006(data,", args = values$args)

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "calc_Huntley2006", args = values$args)
  })

}##EndOf::function(input, output)
