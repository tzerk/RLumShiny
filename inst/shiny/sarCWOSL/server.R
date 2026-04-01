## Server.R
## MAIN FUNCTION
function(input, output, session) {
  options(shiny.maxRequestSize = 30 * 1024^2) # 30MB upload limit

  make_selection <- function(positions, recordTypes) {
    if (length(positions) == 0 || length(recordTypes) == 0)
      return(NULL)

    data_filtered <- values$data_primary[as.numeric(input$positions)]
    data_filtered <- lapply(data_filtered, function(x) {
      subset(x, recordType %in% recordTypes)
    })

    if (length(data_filtered) == 0)
      return(NULL)

    data_filtered
  }

  # input data (with default)
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    object <- Risoe.BINfileData2RLum.Analysis(CWOSL.SAR.Data, pos = 1:2)
  }

  values <- reactiveValues(data_primary = object,
                           data_filtered = NULL,
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

    RLumShiny:::tryNotify(valid.records <- get_RLum(values$data_primary[[1]],
                                                    recordType = c("^OSL", "^IRSL")))
    if (length(valid.records) == 0) {
      return(NULL)
    }
    max.channels <- max(vapply(valid.records, nrow, FUN.VALUE = numeric(1)))
    updateSliderInput(session, "background_integral",
                      value = c(max(max.channels - 100, 10), max.channels),
                      max = max.channels)
  })

  observeEvent(input$positions, {
    values$data_filtered <- make_selection(input$positions, input$recordTypes)
  })

  observeEvent(input$recordTypes, {
    values$data_filtered <- make_selection(input$positions, input$recordTypes)
  })

  observe({
    ## background integral subtraction
    if (input$sub_bg_integral)
      background_integral <- input$background_integral[1]:input$background_integral[2]
    else
      background_integral <- NA

    values$args <- list(
      # analyse_SAR.CWOSL arguments
      object = values$data_filtered %||% values$data_primary,
      signal_integral = input$signal_integral[1]:input$signal_integral[2],
      background_integral = background_integral,
      verbose = FALSE,
      # plot_DoseResponseCurve arguments
      legend = input$showlegend,
      legend.pos = input$legend_pos,
      density_rug = input$showrug,
      # generic plot arguments
      log = paste0("", ifelse(input$logx, "x", ""), ifelse(input$logy, "y", "")),
      main = if (nchar(input$main) > 0) input$main else NULL,
      cex = input$cex,
      plot_onePage = TRUE
    )
  })

  observeEvent(input$signal_integral, {
    ## background integral cannot overlap with signal integral
    updateSliderInput(inputId = "background_integral",
                      min = max(input$signal_integral) + 1)
  })

  output$positions <- renderUI({
    positions <- sort(get_unique_positions(values$data_primary))
    checkboxGroupInput("positions", "Positions",
                       choiceNames = positions,
                       choiceValues = seq_along(positions),
                       selected = seq_along(positions),
                       inline = TRUE)
  })

  output$recordTypes <- renderUI({
    types <- sort(get_unique_types(values$data_primary))
    checkboxGroupInput("recordTypes", "Record types",
                       choices = types,
                       selected = types)
  })

  output$main_plot <- renderPlot({
    set.seed(1)
    values$results <- RLumShiny:::tryNotify(do.call(analyse_SAR.CWOSL, values$args))
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
