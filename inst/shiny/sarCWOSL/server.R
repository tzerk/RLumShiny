## Server.R
## MAIN FUNCTION
function(input, output, session) {
  options(shiny.maxRequestSize = 30 * 1024^2) # 30MB upload limit

  # input data (with default)
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    object <- Risoe.BINfileData2RLum.Analysis(CWOSL.SAR.Data, pos = 1:2)
  }

  values <- reactiveValues(data_primary = object,
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

    values$data_primary <- switch(tools::file_ext(inFile$name),
                                  "xsyg" = read_XSYG2R(inFile$datapath,
                                                       fastForward = TRUE,
                                                       verbose = FALSE)
                                  )
  })

  observeEvent(input$table_in_primary, {
    ## remove existing notifications
    removeNotification(id = "notification")
  })

  observe({
    values$args <- list(
      # analyse_SAR.CWOSL arguments
      object = values$data_primary,
      signal.integral.min = min(input$signal_integral),
      signal.integral.max = max(input$signal_integral),
      background.integral.min = min(input$background_integral),
      background.integral.max = max(input$background_integral),
      legend = input$showlegend,
      legend.pos = input$legend_pos,
      verbose = FALSE,
      # generic plot arguments
      log = paste0("", ifelse(input$logx, "x", ""), ifelse(input$logy, "y", "")),
      main = input$main,
      cex = input$cex,
      plot_onePage = TRUE
    )
  })

  output$main_plot <- renderPlot({
    set.seed(1)
    values$results <- tryNotify(do.call(analyse_SAR.CWOSL, values$args))
    if (inherits(values$results, "RLum.Results")) {
      removeNotification(id = "notification")
    }
  })

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 2, join_inputs_into_list = FALSE,
                              list(name = "analyse_SAR.CWOSL",
                                   arg1 = "data",
                                   args = values$args))

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "analyse_SAR.CWOSL", args = values$args)
  })
}##EndOf::function(input, output)
