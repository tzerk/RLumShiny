## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  values <- reactiveValues(data = if ("startData" %in% names(.GlobalEnv)) startData else ExampleData.DeValues$CA1, 
                           args = NULL)

  session$onSessionEnded(function() {
    stopApp()
  })

  # check and read in file (DATA SET 1)
  observeEvent(input$file1, {
    inFile<- input$file1

    if(is.null(inFile))
      return(NULL) # if no file was uploaded return NULL

    values$data <- fread(file = inFile$datapath, data.table = FALSE) # inFile[1] contains filepath
    if (ncol(values$data) > 2)
      values$data <- values$data[, 1:2]
  })

  # dynamically inject sliderInput for x-axis range
  output$xlim<- renderUI({
    # check if file is loaded
    # # case 1: yes -> slinderInput with custom values
    xlim.plot<- range(hist(values$data[ ,1], plot = FALSE)$breaks)
    
    sliderInput(inputId = "xlim", 
                label = "Range x-axis",
                min = xlim.plot[1]*0.5, 
                max = xlim.plot[2]*1.5,
                value = c(xlim.plot[1], xlim.plot[2]),
                step = 10^(floor(log10(diff(xlim.plot))) - 4))

  })## EndOf::renderUI()

  output$table_in_primary <- renderRHandsontable({
    rhandsontable(values$data,
                  height = 300,
                  colHeaders = c("Dose", "Error"),
                  rowHeaders = NULL)
  })

  observeEvent(input$table_in_primary, {
    res <- rhandsontable_workaround(input$table_in_primary, values)
    if (!is.null(res))
      values$data <- res
  })

  observe({
    # make sure that input panels are registered on non-active tabs.
    # by default tabs are suspended and input variables are hence
    # not available
    outputOptions(x = output, name = "xlim", suspendWhenHidden = FALSE)

    # color of plor elements
    pch.color <- ifelse(input$pchColor == "custom", input$pchRgb, input$pchColor)
    bars.color <- ifelse(input$barsColor == "custom", 
                         adjustcolor(col = input$barsRgb,
                                     alpha.f = input$alpha.bars/100), 
                         adjustcolor(col = input$barsColor,
                                     alpha.f = input$alpha.bars/100))
    rugs.color <- ifelse(input$rugsColor == "custom", input$rugsRgb, input$rugsColor)
    normal.color <- ifelse(input$normalColor == "custom", input$normalRgb, input$normalColor)

    colors<- c(bars.color, rugs.color, normal.color, pch.color)

    values$args <- list(
      data = values$data,
      na.rm = TRUE,
      cex.global = as.numeric(input$cex),
      pch = ifelse(input$pch == "custom", input$custompch, as.integer(input$pch)),
      breaks = ifelse(input$breaks == "custom", input$breaks.num, input$breaks),
      xlim = input$xlim,
      summary.pos = input$sumpos, 
      mtext = input$mtext, 
      main = input$main,
      rug = input$rugs, 
      se = input$errorBars, 
      normal_curve = input$norm, 
      summary = if (input$summary) input$stats else "",
      xlab = input$xlab,
      ylab = c(input$ylab1, input$ylab2),
      colour = colors)
  })

  output$main_plot <- renderPlot({
    validate(need(input$xlim, "Just wait a second..."))
    res <- tryNotify(do.call(plot_Histogram, args = values$args))
    if (inherits(res, "RLum.Results")) {
      ## remove existing notifications
      removeNotification(id = "notification")
    }
  })##EndOf::renderPlot({})

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 1,
                              list(name = "plot_Histogram",
                                   arg1 = "data",
                                   args = values$args))

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "plot_Histogram", args = values$args)
  })

  # renderTable() that prints the data to the second tab
  output$dataset<- DT::renderDT(
    options = list(pageLength = 10, autoWidth = FALSE),
    {
      setNames(values$data, c("De", "De error"))
    })##EndOf::renterTable()

  # reactive function for gVis plots that allow for dynamic input!
  myOptionsCAM<- reactive({
    options<- list(
      page="enable",
      width="500px",
      sort="disable")
    return(options)
  })

  # renderTable() to print the results of the
  # central age model (CAM)
  output$CAM<- DT::renderDT(
    options = list(pageLength = 10, autoWidth = FALSE),
    {
      t<- as.data.frame(matrix(nrow = length(list(values$data)), ncol = 7))
      colnames(t)<- c("Data set","n", "log data", "Central dose", "SE abs.", "OD (%)", "OD error (%)")
      res<- lapply(list(values$data), function(x) { calc_CentralDose(x, verbose = FALSE, plot = FALSE) })
      for(i in 1:length(res)) {
        t[i,1]<- ifelse(i==1,"primary","secondary")
        t[i,2]<- length(res[[i]]@data$data[,1])
        t[i,3]<- res[[i]]@data$args$log
        t[i,4:7]<- round(res[[i]]@data$summary[1:4],2)
      }
      t
    })##EndOf::renterTable()

}##EndOf::function(input, output)
