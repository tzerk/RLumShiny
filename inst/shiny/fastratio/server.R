## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  values <- reactiveValues(data_primary = if ("startData" %in% names(.GlobalEnv)) startData else  ExampleData.CW_OSL_Curve,
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

    values$data_primary <- switch(tools::file_ext(inFile$name),
                                  ## FIXME(mcol): hardcoded curve
                                  "xsyg" = read_XSYG2R(inFile$datapath,
                                                       fastForward = TRUE,
                                                       verbose = FALSE)[[1]]@records[[1]],
                                  "csv" = fread(inFile$datapath,
                                                data.table = FALSE)
                                  )
    if (inherits(values$data_primary, "data.frame") &&
        ncol(values$data_primary) > 2)
      values$data_primary <- values$data_primary[, 1:2]

    updateSliderInput(session, "deadchannels", value = c(1, nrow(values$data_primary)), max = nrow(values$data_primary))
  })

  output$table_in_primary <- renderRHandsontable({
    table_values <- switch(class(values$data_primary)[1],
                           "data.frame" = values$data_primary,
                           "RLum.Data.Curve" = as.data.frame(values$data_primary@data)
                           )

    rhandsontable(table_values,
                  height = 300,
                  colHeaders = c("Time", "Signal"),
                  rowHeaders = NULL)
  })

  observeEvent(input$fitCWsigma, {
    # restore default values (Durcan and Duller, 2011)
    Map(function(id, val) {
      updateNumericInput(session, id, value = val)
    }, c("cs1base", "cs1exp", "cs2base", "cs2exp"), c(2.60, 17, 4.28, 18))
  })

  observeEvent(input$table_in_primary, {
    res <- rhandsontable_workaround(input$table_in_primary, values)
    if (!is.null(res))
      values$data_primary <- res
  })

  observeEvent(input$overrideL1, {
    updateSliderInput(session, "L1", max = nrow(values$data_primary))
  })
  observeEvent(input$overrideL2, {
    updateSliderInput(session, "L2", max = nrow(values$data_primary))
  })
  observeEvent(input$overrideL1, {
    updateSliderInput(session, "L3", max = nrow(values$data_primary))
  })

  observe({
    values$args <- list(
      # calc_FastRatio arguments
      object = values$data_primary,
      stimulation.power = input$stimpow,
      wavelength = input$wavelength,
      sigmaF = input$cs1base * 10^-input$cs1exp,
      sigmaM = input$cs2base * 10^-input$cs2exp,
      Ch_L1 = ifelse(input$overrideL1, input$L1, 1),
      x = input$x,
      x2 = input$x1,
      dead.channels = c(input$deadchannels[1] - 1,
                        max(nrow(values$data_primary) - input$deadchannels[2], 0)),
      fitCW.sigma = input$fitCWsigma,
      fitCW.curve = input$fitCWcurve,
      verbose = FALSE,
      # generic plot arguments
      main = input$main,
      type = input$type,
      pch = ifelse(input$pch == "custom", input$custompch, as.numeric(input$pch)),
      col = ifelse(input$color == "custom", input$jscol1, input$color),
      cex = input$cex,
      xlab = input$xlab,
      ylab = input$ylab,
      log = paste0("", ifelse(input$logx, "x", ""), ifelse(input$logy, "y", ""))
    )

    if (input$overrideL2)
      values$args <- modifyList(isolate(values$args), list(Ch_L2 = input$L2))
    if (input$overrideL3)
      values$args <- modifyList(isolate(values$args), list(Ch_L3 = range(as.numeric(input$L3))))
  })

  output$main_plot <- renderPlot({
    res <- tryNotify(do.call(calc_FastRatio, values$args))
    if (inherits(res, "RLum.Results")) {
      ## remove existing notifications
      removeNotification(id = "notification")
      values$results <- res
    }
  })

  # update numeric input with photoionisation cross-sections calculated
  # by fit_CWCurve()
  observeEvent(values$results, {
  if (input$fitCWsigma) {
    updateNumericInput(session, "cs1base",
                       value = as.numeric(strsplit(as.character(values$results@data$summary$sigmaF), "e-")[[1]][1]))
    updateNumericInput(session, "cs1exp",
                       value = as.numeric(strsplit(as.character(values$results@data$summary$sigmaF), "e-")[[1]][2]))
    updateNumericInput(session, "cs2base",
                       value = as.numeric(strsplit(as.character(values$results@data$summary$sigmaM), "e-")[[1]][1]))
    updateNumericInput(session, "cs2exp",
                       value = as.numeric(strsplit(as.character(values$results@data$summary$sigmaM), "e-")[[1]][2]))
  }
  })

  # Render numeric results in a data table
  output$results <- renderUI({
    res <- get_RLum(values$results)
    HTML(paste0(
      tags$b("Fast ratio: "), signif(res$fast.ratio, 2), " &plusmn; ", signif(res$fast.ratio.se, 2),
      tags$i("(", signif(res$fast.ratio.rse, 2), "% rel. error)"), tags$br(), tags$br(),

      tags$b("  Time (s) | Channel | Counts:"), tags$br(),
      tags$b("L1: "), signif(res$t_L1, 2), " / ", res$Ch_L1, " / ", signif(res$Cts_L1, 2),  tags$br(),
      tags$b("L2: "), signif(res$t_L2, 2), " / ", res$Ch_L2, " / ", signif(res$Cts_L2, 2),  tags$br(),
      tags$b("L3 start: "), signif(res$t_L3_start, 2), " / ", res$Ch_L3_start, " /", tags$br(),
      tags$b("L3 end: "), signif(res$t_L3_end, 2), " / ", res$Ch_L3_end, " / ", signif(res$Cts_L3, 2)
    ))
  })

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 1,
                              list(name = "calc_FastRatio",
                                   arg1 = "data",
                                   args = values$args))

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "calc_FastRatio", args = values$args)
  })

}##EndOf::function(input, output)
