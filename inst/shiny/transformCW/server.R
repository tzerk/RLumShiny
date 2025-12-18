## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  values <- reactiveValues(data_primary = if ("startData" %in% names(.GlobalEnv)) startData else ExampleData.CW_OSL_Curve,
                           tdata = NULL,
                           args = NULL,
                           pargs = NULL)

  session$onSessionEnded(function() {
    stopApp()
  })

  # check and read in file (DATA SET 1)
  observeEvent(input$file, {
    inFile<- input$file

    if(is.null(inFile))
      return(NULL) # if no file was uploaded return NULL

    values$data_primary <- fread(file = inFile$datapath, data.table = FALSE) # inFile[1] contains filepath
    if (ncol(values$data_primary) > 2)
      values$data_primary <- values$data_primary[, 1:2]
  })

  output$table_in_primary <- renderRHandsontable({
    rhandsontable(values$data_primary,
                  height = 300,
                  colHeaders = c("Time", "Signal"),
                  rowHeaders = NULL)
  })

  observeEvent(input$table_in_primary, {
    res <- RLumShiny:::rhandsontable_workaround(input$table_in_primary)
    if (!is.null(res))
      values$data_primary <- res
  })

  # TRANSFORM DATA
  observe({
    P <- input$p
    delta <- input$delta

    # validate method parameters
    if (is.na(input$delta) || input$delta < 1) {
      updateNumericInput(session, "delta", value = 1)
      delta <- 1
    }

    # validate method parameters
    if (is.na(input$p) || input$p < 1) {
      updateNumericInput(session, "p", value = 1)
      P <- 1
    }

    args <- list(values$data_primary)
    if (input$method == "convert_CW2pHMi")
        args <- append(args, delta)
    if (input$method == "convert_CW2pLMi" || input$method == "convert_CW2pPMi")
        args <- append(args, P)

    values$args <- args

    # values$export_args <- args
    values$tdata <- RLumShiny:::tryNotify(do.call(input$method, args))
  })

  output$main_plot <- renderPlot({
    # be reactive on method changes
    input$method
    input$delta
    input$p

    if (inherits(values$tdata, "try-error")) {
      plot(1, type="n", axes=F, xlab="", ylab="")
      text(1, labels = paste(values$tdata, collapse = "\n"))
      return()
    }

    log <- paste0(ifelse(input$logx, "x", ""), ifelse(input$logy, "y", ""))
    values$pargs <- list(values$tdata[, 1], values$tdata[, 2],
                  log = log,
                  main = input$main,
                  xlab = input$xlab,
                  ylab = input$ylab1,
                  type = input$type,
                  pch = ifelse(input$pch == "custom", input$custompch, as.integer(input$pch)),
                  col = ifelse(input$color != "custom", input$color, input$jscol1),
                  bty = "n")

    par(mar=c(5,4,4,5)+.1, cex = input$cex)
    do.call(plot, values$pargs)

    if (input$showCW) {
      par(new = TRUE)
      plot(values$data_primary, 
           axes = FALSE, 
           xlab = NA, 
           ylab = NA, 
           col = "red", 
           type = input$type,
           log = log)
      axis(side = 4, col = "red", col.axis = "red")
      mtext(input$ylab2, side = 4, line = 3, col = "red", cex = input$cex)
    }

    output$exportScript <- downloadHandler(
      filename = function() { "transformedCW.txt" },
      content = function(file) {
        write.table(values$tdata, file, sep = ",", quote = FALSE, row.names = FALSE)
      },#EO content =,
      contentType = "text"
    )#EndOf::dowmloadHandler()
  })

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 1,
                              list(name = input$method,
                                   arg1 = "data",
                                   args = values$pargs))

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "plot", args = values$pargs)
  })

  output$dataset <- DT::renderDT({
    if (!is.null(values$tdata))
      values$tdata
  })

}##EndOf::function(input, output)
