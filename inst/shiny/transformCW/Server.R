## Server.R
## MAIN FUNCTION
function(input, output, session) {
  
  # RECEIVE USER DATA ----
  observeEvent(input$file, {
    
    inFile<- input$file
    if(is.null(inFile)) 
      return(NULL) 
    
    t <- tryCatch(read.table(file = inFile$datapath,
                             sep = input$sep, 
                             quote = "", 
                             header = input$headers),
                  error = function(e) {
                    return(NULL)
                  })
    
    if (is.null(t))
      return(NULL)
    
    if (ncol(t) == 1)
      return(NULL)
    
    data <<- t
  })
  
  # TRANSFORM DATA
  observe({
    
    # be reactive to..
    input$file
    input$inputdata
    
    P <- input$p
    delta <- input$delta
    
    # validate method parameters
    if (is.na(input$delta)) {
      updateNumericInput(session, "delta", value = 1)
      delta <- 1
    }
    else if (input$delta < 1) {
      updateNumericInput(session, "delta", value = 1)
      delta <- 1
    }
    
    # validate method parameters
    if (is.na(input$p)) {
      updateNumericInput(session, "p", value = 1)
      P <- 1
    }
    else if (input$p < 1) {
      updateNumericInput(session, "p", value = 1)
      P <- 1
    }

    args <- list(data)
    if (input$method == "CW2pHMi")
      if (delta >= 1)
        args <- append(args, delta)
    if (input$method == "CW2pLMi" || input$method == "CW2pPMi")
      if (P >= 1)
        args <- append(args, P)
    
    tdata <<- tryCatch({
      do.call(input$method, args)
    },
    error = function(e) {
      return(NULL)
    })
  })
  
  # Observe changes in output table and update the data set
  observeEvent(input$inputdata ,{
    if(exists("tdata") && !is.null(input$inputdata)) {
      data <<- hot_to_r(input$inputdata)
    }
  })
  
  output$main_plot <- renderPlot({
    
    # be reactive on method changes
    input$file
    input$inputdata
    input$method
    input$delta
    input$p
    
    # plot settings
    pargs <- list(NA, NA, 
                  log = paste0(ifelse(input$logx, "x", ""), ifelse(input$logy, "y", "")),
                  main = input$main,
                  xlab = input$xlab,
                  ylab = input$ylab,
                  cex = input$cex,
                  xlim = c(min(c(tdata[,1], data[,1])), max(c(tdata[,1], data[,1]))),
                  ylim = c(min(c(tdata[,2], data[,2])), max(c(tdata[,2], data[,2]))),
                  type = input$type,
                  pch = ifelse(input$pch != "custom", as.integer(input$pch) - 1, input$custompch),
                  col = ifelse(input$color != "custom", input$color, input$jscol1))
    
    # create empty plot and add both input and output curves
    do.call(plot, pargs)
    lines(tdata[,1:2])
    lines(data, col = "red")
    legend(x = "topright", legend = c("CW-OSL (input)", "pseudo-OSL (output)"), lty = c(1,1), col = c("red", "black"))
    
    output$exportScript <- downloadHandler(
      filename = function() { paste(input$filename, ".", "txt", sep="") },
      content = function(file) {
        write.table(tdata, file, sep = ",", quote = FALSE, row.names = FALSE)
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
        do.call(plot, args = pargs)
        lines(tdata[,1:2])
        lines(data, col = "red")
        legend(x = "topright", legend = c("CW-OSL (input)", "pseudo-OSL (output)"), lty = c(1,1), col = c("red", "black"))
        
        dev.off()
      },#EO content =,
      contentType = "image"
    )#EndOf::dowmloadHandler()
  })
  
  output$dataset <- renderRHandsontable({
    # be reactive on method changes
    input$file
    input$inputdata
    input$method
    input$delta
    input$p
    
    if (exists("tdata")){
      rhandsontable(tdata, readOnly = TRUE)
    }
  })
  
  output$inputdata <- renderRHandsontable({
    
    input$inputdata
    input$file
    
    # be reactive on method changes
    if (!is.null(data))
      rhandsontable(data)
    else
      rhandsontable(data)
  })
  

}##EndOf::function(input, output)