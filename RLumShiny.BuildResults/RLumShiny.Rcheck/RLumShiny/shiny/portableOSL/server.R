## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    data <- merge_RLum(ExampleData.portableOSL)

    ## add coordinates so that the surface mode works
    sample.names <- unique(sapply(data@records, function(x) x@info$settings$Sample))
    data@records <- lapply(data@records, function(x) {
      name <- x@info$settings$Sample
      set.seed(match(name, sample.names))
      x@info$settings$Sample <- paste0(name, "_x:", runif(1), "|y:", runif(1))
      x
    })
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
    values$results <- do.call(analyse_portableOSL, values$args)
  })

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode", n_input = 1,
                              fun = "analyse_portableOSL(data,", args = values$args)

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "analyse_portableOSL", args = values$args)
  })

}##EndOf::function(input, output)
