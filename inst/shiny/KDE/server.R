## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  values <- reactiveValues(data_primary = if ("startData" %in% names(.GlobalEnv)) startData else ExampleData.DeValues$CA1,
                           data_secondary = setNames(as.data.frame(matrix(NA_real_, nrow = 5, ncol = 2)), c("x", "y")),
                           data = NULL,
                           args = NULL)

  session$onSessionEnded(function() {
    stopApp()
  })

  # check and read in file (DATA SET 1)
  observeEvent(input$file1, {
    inFile<- input$file1

    if(is.null(inFile))
      return(NULL) # if no file was uploaded return NULL

    values$data_primary <- fread(file = inFile$datapath, data.table = FALSE) # inFile[1] contains filepath
    if (ncol(values$data_primary) > 2)
      values$data_primary <- values$data_primary[, 1:2]
  })

  # check and read in file (DATA SET 2)
  observeEvent(input$file2, {
    inFile<- input$file2

    if(is.null(inFile))
      return(NULL) # if no file was uploaded return NULL

    values$data_secondary <- fread(file = inFile$datapath, data.table = FALSE) # inFile[1] contains filepath
    if (ncol(values$data_secondary) > 2)
      values$data_secondary <- values$data_secondary[, 1:2]
  })

  ### GET DATA SETS
  observe({
    ### GET DATA
    data <- list(values$data_primary, values$data_secondary)
    data <- lapply(data, function(x) {
      x_tmp <- x[complete.cases(x), ]
      if (nrow(x_tmp) == 0) return(NULL)
      else return(x_tmp)
    })
    data <- data[!sapply(data, is.null)]
    data <- lapply(data, function(x) setNames(x, c("Dose", "Error")))

    values$data <- data
  })

  output$table_in_primary <- renderRHandsontable({
    ## remove existing notifications
    removeNotification(id = "notification")

    rhandsontable(values$data_primary,
                  height = 300,
                  colHeaders = c("Dose", "Error"),
                  rowHeaders = NULL)
  })

  observeEvent(input$table_in_primary, {
    res <- rhandsontable_workaround(input$table_in_primary, values)
    if (!is.null(res))
      values$data_primary <- res
  })

  output$table_in_secondary <- renderRHandsontable({
    ## remove existing notifications
    removeNotification(id = "notification")

    rhandsontable(values$data_secondary,
                  height = 300,
                  colHeaders = c("Dose", "Error"),
                  rowHeaders = NULL)
  })

  observeEvent(input$table_in_secondary, {
    res <- rhandsontable_workaround(input$table_in_secondary, values)
    if (!is.null(res))
      values$data_secondary <- res
  })

  # dynamically inject sliderInput for x-axis range
  output$xlim<- renderUI({
    data <- do.call(rbind, values$data)
    rng <- range(data[, 1])
    sliderInput(inputId = "xlim",
                label = "Range x-axis",
                min = signif(rng[1] * 0.25, 3),
                max = signif(rng[2] * 1.75, 3),
                value = rng * c(0.9, 1.1))
  })## EndOf::renderUI()

  # dynamically inject sliderInput for KDE bandwidth
  output$bw<- renderUI({
    data <- do.call(rbind, values$data)
    bw <- bw.nrd0(data[, 1])
    sliderInput(inputId = "bw",
                label = "KDE bandwidth",
                min = signif(bw / 4, 3),
                max = signif(bw * 4, 3),
                value = bw)
  })## EndOf::renderUI()

  observe({
    # make sure that input panels are registered on non-active tabs.
    # by default tabs are suspended and input variables are hence
    # not available
    outputOptions(x = output, name = "xlim", suspendWhenHidden = FALSE)
    outputOptions(x = output, name = "bw", suspendWhenHidden = FALSE)

    # refresh plot on button press
    input$refresh

    # check if any summary stats are activated, else NA
    summary <- if (input$summary) input$stats else ""

    # if custom datapoint color get RGB code from separate input panel
    color <- ifelse(input$color == "custom", input$rgb, input$color)

    # if custom datapoint color get RGB code from separate input panel
    if(!all(is.na(unlist(values$data_secondary)))) {
      color2 <- ifelse(input$color2 == "custom", input$rgb2, input$color2)
    } else {
      color2<- adjustcolor("white", alpha.f = 0)
    }

    values$args <- list(
      data = values$data,
      cex = input$cex,
      log = ifelse(input$logx, "x", ""),
      xlab = input$xlab,
      ylab = c(input$ylab1, input$ylab2),
      main = input$main,
      values.cumulative = input$cumulative,
      na.rm = TRUE,
      rug = input$rug,
      boxplot = input$boxplot,
      summary = summary,
      summary.pos = input$sumpos,
      summary.method = input$summary.method,
      bw = as.numeric(input$bw),
      xlim = input$xlim,
      col = c(color, color2))
  })

  output$main_plot <- renderPlot({
    # validate(need()) makes sure that all data are available to
    # renderUI({}) before plotting and will wait until there
    validate(
      need(expr = input$xlim, message = ''),
      need(expr = input$bw, message = 'Waiting for data... Please wait!')
    )

    res <- tryNotify(do.call(plot_KDE, args = values$args))
    if (inherits(res, "RLum.Results"))
      res
  })##EndOf::renderPlot({})

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = ifelse(!all(is.na(unlist(values$data_secondary))), 2, 1),
                              list(name = "plot_KDE",
                                   arg1 = "data",
                                   args = values$args))

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "plot_KDE", args = values$args)
  })

  # renderTable() that prints the data to the second tab
  output$dataset<- DT::renderDT(
    options = list(pageLength = 10, autoWidth = FALSE),
    {
      data <- values$data[[1]]
      colnames(data) <- c("De","De error")
      data

    })##EndOf::renderDT()

  # renderTable() that prints the secondary data to the second tab
  output$dataset2<- DT::renderDT(
    options = list(pageLength = 10, autoWidth = FALSE),
    {
      if(!all(is.na(unlist(values$data_secondary)))) {
        data <- values$data[[2]]
        colnames(data) <- c("De","De error")
        data
      } else {
      }
    })##EndOf::renderDT()

  # renderTable() to print the results of the
  # central age model (CAM)
  output$CAM<- DT::renderDT(
    options = list(pageLength = 10, autoWidth = FALSE),
    {

      data <- values$data

      t<- as.data.frame(matrix(nrow = length(data), ncol = 7))
      colnames(t)<- c("Data set","n", "log data", "Central dose", "SE abs.", "OD (%)", "OD error (%)")
      res<- lapply(data, function(x) { calc_CentralDose(x, verbose = FALSE, plot = FALSE) })
      for(i in 1:length(res)) {
        t[i,1]<- ifelse(i==1,"primary","secondary")
        t[i,2]<- length(res[[i]]@data$data[,1])
        t[i,3]<- res[[i]]@data$args$log
        t[i,4:7]<- round(res[[i]]@data$summary[1:4],2)
      }
      t
    })##EndOf::renderDT()

}##EndOf::shinyServer(function(input, output)
