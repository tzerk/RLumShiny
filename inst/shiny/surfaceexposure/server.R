## Server.R
## MAIN FUNCTION
function(input, output, session) {
  
  # input data (with default)
  values <- reactiveValues(data = example_data, data_used = NULL, args = NULL, results = NULL)
  
  observe({
    # make sure that input panels are registered on non-active tabs.
    # by default tabs are suspended and input variables are hence
    # not available
    outputOptions(x = output, name = "global_fit_ages", suspendWhenHidden = FALSE)
  })
  
  session$onSessionEnded(function() {
    stopApp()
  })
  
  # check and read in file (DATA SET 1)
  observeEvent(input$file, {
    inFile<- input$file
    
    if(is.null(inFile)) 
      return(NULL) # if no file was uploaded return NULL
    
    data <- fread(file = inFile$datapath, data.table = FALSE) # inFile[1] contains filepath
    
    if (ncol(data) == 2) {
      data$error <- 0.0001
      data$group <- as.factor("A")
    } else if (ncol(data) == 3) {
      data$group <- as.factor("A")
    }
    
    colnames(data) <- c("x", "y", "error", "group")
    
    updateCheckboxInput(session, "global_fit", value = FALSE)
    
    values$data <- data
  })
  
  output$table_in_primary <- renderRHandsontable({
    rhandsontable(values$data,
                  height = 300, 
                  colHeaders = c("Depth", "Signal", "Error", "Group"), 
                  rowHeaders = NULL)
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
      values$data <- hot_to_r(df_tmp)
    
  })
  
  output$global_fit_ages <- renderUI({
    if (input$global_fit && inherits(values$data_used, "list")) {
      lapply(1:length(values$data_used), function(i) {
        numericInput(paste0("age_", i), paste("Age", i), value = 10^(2+i))
      })
    }
  })
  
  observeEvent(input$coord_flip, {
    tmp <- isolate(input$xlab)
    updateTextInput(session, "xlab", value = isolate(input$ylab))
    updateTextInput(session, "ylab", value = tmp)
  }, ignoreInit = TRUE)
  
  # update for log values
  observe({
    if (input$logy)
      updateSliderInput(session, "ylim", value = c(0.1, isolate(input$ylim[2])), min = 0.1)
    else
      updateSliderInput(session, "ylim", 
                        min = min(values$data[ ,2]) - diff(range(values$data[ ,2])) / 2, 
                        max = max(values$data[ ,2]) + diff(range(values$data[ ,2])) / 2, 
                        value = range(pretty(values$data[ ,2])))
    
  })
  
  # update for log values
  observe({
    if (input$logx)
      updateSliderInput(session, "xlim", value = c(0.1, isolate(input$xlim[2])), min = 0.1)
    else
      updateSliderInput(session, "xlim", 
                        min = min(values$data[ ,1]) - diff(range(values$data[ ,1])) / 2, 
                        max = max(values$data[ ,1]) + diff(range(values$data[ ,1])) / 2, 
                        value = range(pretty(values$data[ ,1])))
  })
  
  
  observe({
    
    if (input$global_fit) {
      
      # split data frame to list
      if (!all(is.na(values$data$group))) {
        data <- values$data[complete.cases(values$data), ]
        NA_index <- which(data$group == "")
        if (length(NA_index) > 0)
          data <- data[-NA_index, ]
        
        data$group <- droplevels(data$group)
        
        data <- split(data, data$group)
        # remove any list element with data.frames with 0 rows
        data <- lapply(data, function(x) if (nrow(x) != 0) x else NULL )
        data[sapply(data, is.null)] <- NULL
        values$data_used <- lapply(data, function(x) x[ ,1:2])
      }
    } else {
      values$data_used <- values$data
    }
    
    # Age
    if (input$global_fit) {
      age <- sapply(1:length(values$data_used), function(i) as.numeric(input[[paste0("age_", i)]]))
    } else {
      if (input$override_age)
        age <- input$age
      else
        age <- NULL
    }
    
    values$args <- list(
      data = values$data_used,
      age = age,
      weights = if (input$global_fit) FALSE else input$weights,
      sigmaphi = if (input$override_sigmaphi) input$sigmaphi_base * 10^-(abs(input$sigmaphi_exp)) else NULL,
      mu = if (input$override_mu) input$mu else NULL,
      Ddot = if (input$doserate) input$ddot else NULL,
      D0  = if (input$doserate) input$d0 else NULL,
      verbose = FALSE,
      pch = ifelse(input$pch == "custom", input$custompch, as.numeric(input$pch) - 1),
      bg = ifelse(input$color == "custom", input$jscol1, input$color),
      cex = input$cex,
      legend = input$legend,
      main = input$main,
      line_col = ifelse(input$line_col == "custom", input$jscol2, input$line_col),
      line_lty = as.numeric(input$lty),
      line_lwd = as.numeric(input$lwd),
      xlab = input$xlab,
      ylab = input$ylab,
      log = paste0("", ifelse(input$logx, "x", ""), ifelse(input$logy, "y", "")),
      coord_flip = input$coord_flip,
      error_bars = input$error_bars,
      xlim = if (!input$coord_flip) input$xlim else input$ylim,
      ylim = if (!input$coord_flip) input$ylim else rev(input$xlim))
    
  })
  
  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode", n_input = 1, 
                              fun = paste0("fit_SurfaceExposure(data,"), args = values$args)
    
    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})
    
    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "fit_SurfaceExposure", args = values$args)
  })
  
  ## MAIN ----
  output$main_plot <- renderPlot({
    values$results <- do.call(fit_SurfaceExposure, values$args)
  })
  
  output$console <- renderText({
    if (is.null(values$results))
      return(NULL)
    
    if (!input$global_fit) {
      res <- as.data.frame(t(signif(unlist(get_RLum(values$results)), 3)))
      
      HTML(paste0(
        tags$b("Age (a): "), res$age, " &plusmn; ", res$age_error, tags$em(ifelse(input$override_age, "(fixed)", "")), tags$br(), 
        tags$b("sigmaPhi: "), res$sigmaphi, " &plusmn; ", res$sigmaphi_error, tags$em(ifelse(input$override_sigmaphi, "(fixed)", "")), tags$br(),
        tags$b("mu: "), res$mu, " &plusmn; ", res$mu_error, tags$em(ifelse(input$override_mu, "\t(fixed)", "")), tags$br()
      ))
    } else {
      res <- as.data.frame(get_RLum(values$results))
      
      print(str(res))
      HTML(paste0(
        tags$b("Ages (a): "), paste(res$age, collapse = ", "), tags$em(" (fixed)"), tags$br(), 
        tags$b("sigmaPhi: "), signif(unique(res$sigmaphi), 3), " &plusmn; ", signif(unique(res$sigmaphi_error), 3), tags$em(ifelse(input$override_sigmaphi, "(fixed)", "")), tags$br(),
        tags$b("mu: "), signif(unique(res$mu), 3), " &plusmn; ", signif(unique(res$mu_error), 3), tags$em(ifelse(input$override_mu, "\t(fixed)", "")), tags$br()
      ))
    }
  })
  
  
}##EndOf::function(input, output)