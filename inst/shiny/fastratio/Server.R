## Server.R
## MAIN FUNCTION
function(input, output, session) {
  
  # input data (with default)
  values <- reactiveValues(data_primary = ExampleData.CW_OSL_Curve)
  
  # check and read in file (DATA SET 1)
  observeEvent(input$file, {
    inFile<- input$file
    
    if(is.null(inFile)) 
      return(NULL) # if no file was uploaded return NULL
    
    values$data_primary <- fread(file = inFile$datapath, data.table = FALSE) # inFile[1] contains filepath
    updateSliderInput(session, "deadchannels", value = c(1, nrow(values$data_primary)), max = nrow(values$data_primary))
  })
  
  output$table_in_primary <- renderRHandsontable({
    rhandsontable(values$data_primary, 
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
  
  observeEvent(input$overrideL1, {
    updateSliderInput(session, "L1", max = nrow(values$data_primary))
  })
  observeEvent(input$overrideL2, {
    updateSliderInput(session, "L2", max = nrow(values$data_primary))
  })
  observeEvent(input$overrideL1, {
    updateSliderInput(session, "L3", max = nrow(values$data_primary))
  })
  
  output$main_plot <- renderPlot({
    
    
    
    pargs <- list(
      # calc_FastRatio arguments
      object = values$data_primary[input$deadchannels[1]:input$deadchannels[2], ],
      stimulation.power = input$stimpow,
      wavelength = input$wavelength,
      sigmaF = input$cs1base * 10^-input$cs1exp,
      sigmaM = input$cs2base * 10^-input$cs2exp, 
      Ch_L1 = ifelse(input$overrideL1, input$L1, 1), 
      x = input$x, 
      x2 = input$x1, 
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
      log = ""
    )
    
    if (input$logx)
      pargs$log <- paste0(pargs$log, "x")
    if (input$logy)
      pargs$log <- paste0(pargs$log, "y")
    
    if (input$overrideL2)
      pargs <- modifyList(pargs, list(Ch_L2 = input$L2))
    if (input$overrideL3)
      pargs <- modifyList(pargs, list(Ch_L3 = range(as.numeric(input$L3))))
    
    results <- do.call(calc_FastRatio, pargs)
    
    # update numeric input with photoionisation cross-sections calculated
    # by fit_CWCurve()
    if (input$fitCWsigma) {
      updateNumericInput(session, "cs1base",
                         value = as.numeric(strsplit(as.character(results@data$summary$sigmaF), "e-")[[1]][1]))
      updateNumericInput(session, "cs1exp",
                         value = as.numeric(strsplit(as.character(results@data$summary$sigmaF), "e-")[[1]][2]))
      updateNumericInput(session, "cs2base",
                         value = as.numeric(strsplit(as.character(results@data$summary$sigmaM), "e-")[[1]][1]))
      updateNumericInput(session, "cs2exp",
                         value = as.numeric(strsplit(as.character(results@data$summary$sigmaM), "e-")[[1]][2]))
    }
    
    # Render numeric results in a data table
    output$results <- renderUI({
      res <- get_RLum(results)
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
    
    
    # prepare code as text output
    str1 <- "data <- data.table::fread(file, data.table = FALSE)"
    
    header <- paste("# To reproduce the plot in your local R environment",
                    "# copy and run the following code to your R console.",
                    "library(Luminescence)",
                    "file <- file.choose()",
                    str1,
                    "\n",
                    sep = "\n")
    
    names <- names(pargs)
    
    verb.arg <- paste(mapply(function(name, arg) {
      if (all(inherits(arg, "character")))
        arg <- paste0("'", arg, "'")
      if (length(arg) > 1)
        arg <- paste0("c(", paste(arg, collapse = ", "), ")")
      if (is.null(arg))
        arg <- "NULL"
      paste(name, "=", arg) 
    }, names[-1], pargs[-1]), collapse = ",\n")
    
    funCall <- paste0("calc_FastPlot(data = data,\n", verb.arg, ")")
    
    code.output <- paste0(header, funCall, collapse = "\n")
    
    # nested renderText({}) for code output on "R plot code" tab
    output$plotCode<- renderText({
      
      code.output
      
    })##EndOf::renderText({})
    
    
    output$exportScript <- downloadHandler(
      filename = function() { paste(input$filename, ".", "R", sep="") },
      content = function(file) {
        write(code.output, file)
      },#EO content =,
      contentType = "text"
    )#EndOf::dowmloadHandler()
    
    
    # nested downloadHandler() to print plot to file
    output$exportFile <- downloadHandler(
      filename = function() { paste(input$filename, ".", input$fileformat, sep="") },
      content = function(file) {
        
        # determine desired fileformat and set arguments
        if(input$fileformat == "pdf") {
          pdf(file, 
              width = input$imgwidth, 
              height = input$imgheight, 
              paper = "special",
              useDingbats = FALSE, 
              family = input$fontfamily)
        }
        if(input$fileformat == "svg") {
          svg(file, 
              width = input$imgwidth, 
              height = input$imgheight, 
              family = input$fontfamily)
        }
        if(input$fileformat == "eps") {
          postscript(file, 
                     width = input$imgwidth, 
                     height = input$imgheight, 
                     paper = "special", 
                     family = input$fontfamily)
        }
        
        # plot curve 
        do.call(calc_FastRatio, pargs)
        
        dev.off()
      },#EO content =,
      contentType = "image"
    )#EndOf::dowmloadHandler()
  })
  
}##EndOf::function(input, output)