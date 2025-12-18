## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    data <- values.curve
    data.bg <- values.curveBG
  }

  values <- reactiveValues(data_primary = data,
                           data_bg = data.bg,
                           args = NULL,
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
    if (ncol(values$data_primary) > 2)
      values$data_primary <- values$data_primary[, 1:2]
  })

  # check and read in file (BG DATA SET)
  observeEvent(input$file_bg, {
    inFile <- input$file_bg
    if(is.null(inFile))
      return(NULL) # if no file was uploaded return NULL

    values$data_bg <- fread(file = inFile$datapath, data.table = FALSE) # inFile[1] contains filepath
    if (ncol(values$data_bg) > 2)
      values$data_bg <- values$data_bg[, 1:2]
  })

  observeEvent(input$table_in_primary, {
    res <- RLumShiny:::rhandsontable_workaround(input$table_in_primary)
    if (!is.null(res))
      values$data_primary <- res
  })

  observeEvent(input$table_bg, {
    res <- RLumShiny:::rhandsontable_workaround(input$table_bg)
    if (!is.null(res))
      values$data_bg <- res
  })

  observe({
    values$args <- list(
      # fit_LMCurve arguments
      values = values$data_primary,
      values.bg = values$data_bg,
      n.components = input$n_components,
      bg.subtraction = input$bg_subtraction,
      input.dataType = input$datatype,
      LED.power = input$LED_power,
      LED.wavelength = input$LED_wavelength,
      legend = input$showlegend,
      legend.pos = input$legend_pos,
      plot.residuals = input$plot_residuals,
      plot.contribution = input$plot_contribution,
      verbose = FALSE,
      # generic plot arguments
      log = paste0("", ifelse(input$logx, "x", ""), ifelse(input$logy, "y", "")),
      main = input$main,
      cex = input$cex
    )
  })

  output$main_plot <- renderPlot({
    res <- RLumShiny:::tryNotify(do.call(fit_LMCurve, values$args))
    if (inherits(res, "RLum.Results")) {
      if (!inherits(res$fit, "try-error")) {
        ## remove existing notifications
        removeNotification(id = "notification")
      }
      values$results <- res
    }
  })

  output$table_in_primary <- renderRHandsontable({
    rhandsontable(values$data_primary,
                  height = 300,
                  colHeaders = c("Time", "Counts"),
                  rowHeaders = NULL)
  })

  output$table_bg <- renderRHandsontable({
    rhandsontable(values$data_bg,
                  height = 300,
                  colHeaders = c("Time", "Counts"),
                  rowHeaders = NULL)
  })

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 2, join_inputs_into_list = FALSE,
                              list(name = "fit_LMCurve",
                                   arg1 = "values = data1,\nvalues.bg = data2",
                                   args = values$args[-2])) # remove values.bg

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "fit_LMCurve", args = values$args)
  })

  ## render the results for the photoionisation cross-section (CS)
  output$CS<- DT::renderDT(options = list(dom = 't'), {
    fit <- do.call(fit_LMCurve, c(values$args, plot = FALSE))
    res <- fit@data$data

    ## photoionisation cross-section results
    cols <- paste0(c("cs", "rel_cs"), rep(1:input$n_components, each = 2))
    cs.abs <- res[, cols]
    cs.rel <- res[, cols]
    vals <- data.frame(comp = 1:input$n_components,
                       cs = as.numeric(cs.abs),
                       rel = as.numeric(cs.rel))
    colnames(vals) <- c("Component", "Cross-section [cm²]", "Relative")
    vals
  })##EndOf::renderDT()

}##EndOf::function(input, output)
