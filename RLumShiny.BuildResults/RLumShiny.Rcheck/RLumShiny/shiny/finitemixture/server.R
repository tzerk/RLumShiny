## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    data <- ExampleData.DeValues$CA1
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
      # calc_FiniteMixture arguments
      data = values$data_primary,
      sigmab = input$sigmab,
      n.components = input$n_components[1]:input$n_components[2],
      pdf.weight = input$pdf_weight,
      pdf.sigma = if (input$pdf_sigma) "sigma" else "se",
      pdf.colors = input$pdf_colors,
      plot.proportions = input$plot_proportions,
      plot.criteria = input$plot_criteria,
      verbose = FALSE,
      # generic plot arguments
      main = input$main,
      main.densities = input$main_densities,
      main.proportions = input$main_proportions,
      main.criteria = input$main_criteria,
      cex = input$cex
    )
  })

  output$main_plot <- renderPlot({
    values$results <- do.call(calc_FiniteMixture, values$args)
  })

  output$table_in_primary <- renderRHandsontable({
    rhandsontable(values$data_primary,
                  height = 300,
                  colHeaders = c("Dose", "Error"),
                  rowHeaders = NULL)
  })

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode", n_input = 1,
                              fun = "calc_FiniteMixture(data,", args = values$args)

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "calc_FiniteMixture", args = values$args)
  })

}##EndOf::function(input, output)
