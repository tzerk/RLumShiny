## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    data <- RF70Curves[[1]]
  }
  values <- reactiveValues(data_primary = data,
                           args = NULL,
                           results = NULL)

  session$onSessionEnded(function() {
    stopApp()
  })

  ## check and read in file (natural curve)
  observeEvent(input$nat, {
    inFile <- input$nat
    if (is.null(inFile))
      return(NULL) # if no file was uploaded return NULL

    ## remove existing notifications
    removeNotification(id = "notification")

    nat <- fread(file = inFile$datapath, data.table = FALSE)
    if (ncol(nat) > 2)
      nat <- nat[, 1:2]
    values$data_primary@records[[1]]@data <- as.matrix(nat)
  })

  ## check and read in file (regenerated curve)
  observeEvent(input$reg, {
    inFile <- input$reg
    if (is.null(inFile))
      return(NULL) # if no file was uploaded return NULL

    ## remove existing notifications
    removeNotification(id = "notification")

    reg <- fread(file = inFile$datapath, data.table = FALSE)
    if (ncol(reg) > 2)
      reg <- reg[, 1:2]
    values$data_primary@records[[2]]@data <- as.matrix(reg)
  })

  output$RF_nat <- renderUI({
    max.nat <- nrow(values$data_primary[[1]])
    sliderInput(inputId = "RF_nat",
                label = "Natural signal",
                min = 1, max = max.nat,
                value = c(1, max.nat),
                step = 1)
  })

  output$RF_reg <- renderUI({
    max.reg <- nrow(values$data_primary[[2]])
    sliderInput(inputId = "RF_reg",
                label = "Regenerated signal",
                min = 1, max = max.reg,
                value = c(1, max.reg),
                step = 1)
  })

  observe({
    values$args <- list(
      # analyse_IRSAR.RF arguments
      object = values$data_primary,
      method = input$method,
      RF_nat.lim = input$RF_nat,
      RF_reg.lim = input$RF_reg,
      n.MC = if (input$n_MC == 0) NULL else input$n_MC,
      method_control = list(show_density = input$show_density,
                            show_fit = input$show_fit),
      plot_reduced = !input$show_residuals,
      verbose = FALSE,
      # generic plot arguments
      main = input$main,
      cex = input$cex,
      xlab = input$xlab,
      ylab = input$ylab,
      log = paste0(ifelse(input$logx, "x", ""), ifelse(input$logy, "y", "")),
      legend = input$legend,
      legend.pos = input$legend_pos
    )
    outputOptions(x = output, name = "ylab", suspendWhenHidden = FALSE)
  })

  output$main_plot <- renderPlot({
    res <- tryNotify(do.call(analyse_IRSAR.RF, values$args))
    if (inherits(res, "RLum.Results"))
      values$results <- res
  })

  output$table_natural <- renderRHandsontable({
    rhandsontable(values$data_primary@records[[1]]@data,
                  height = 300,
                  colHeaders = c("Time", "Signal"),
                  rowHeaders = NULL)
  })

  output$table_regenerated <- renderRHandsontable({
    rhandsontable(values$data_primary@records[[2]]@data,
                  height = 300,
                  colHeaders = c("Time", "Signal"),
                  rowHeaders = NULL)
  })

  output$ylab <- renderUI({
    struct <- structure_RLum(values$data_primary)
    resolution.RF <- round(mean(struct$x.max / struct$n.channels), digits = 1)
    textInput(inputId = "ylab",
              label = "Label y-axis",
              value = paste0("IR-RF [cts / ", resolution.RF, "s]"))
  })


  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 2, join_inputs_into_list = FALSE,
                              list(name = "set_RLum",
                                   arg1 = '"RLum.Analysis"',
                                   args = list(dummy = NA,  # the first argument is removed by printCode()
                                               records = expression(
                                                   list(set_RLum("RLum.Data.Curve", data = as.matrix(data1)),
                                                        set_RLum("RLum.Data.Curve", data = as.matrix(data2))))),
                                   rets = "data",
                                   info = "create an RLum.Analysis object"),
                              list(name = "analyse_IRSAR.RF",
                                   arg1 = "data",
                                   args = values$args))

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "analyse_IRSAR.RF", args = values$args)
  })

}##EndOf::function(input, output)
