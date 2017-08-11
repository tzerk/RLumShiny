## Server.R
## MAIN FUNCTION
function(input, output, session) {
  
  # input data (with default)
  values <- reactiveValues(data = NULL, data_filtered = NULL, positions = NULL, types = NULL)
  
  # check and read in file (DATA SET 1)
  observeEvent(input$import, {
    inFile<- input$file
    
    if(is.null(inFile)) 
      return(NULL)
    
    # 1. Risoe .bin(x)
    if (tools::file_ext(inFile$name) == "bin" || tools::file_ext(inFile$name) == "binx") {
      
      # rename temp file
      file <- paste0(inFile$datapath, ".", tools::file_ext(inFile$name))
      file.rename(inFile$datapath, file)
      
      # import the file
      values$data <- read_BIN2R(file, fastForward = TRUE, verbose = FALSE)
      
      # set some diagnostic values
      values$positions <- unique(sapply(values$data, function(x) { x@records[[1]]@info$POSITION }))
      values$types <- unique(sapply(values$data[[1]]@records, function(x) { x@recordType }))
    }
    
  })
  
  output$positions <- renderUI({
    if (!is.null(values$positions))
      checkboxGroupInput("positions", "Positions", 
                         choiceNames = as.character(values$positions), choiceValues = 1:length(values$positions), 
                         selected = 1:length(values$positions),
                         inline = TRUE)
  })
  
  output$types <- renderUI({
    if (!is.null(values$types))
      checkboxGroupInput("recordTypes", "Record types", 
                         choices = values$types, selected = values$types)
  })
  
  
  ## FILTER ----
  observe({
    if (is.null(values$data))
      return(NULL)
    
    data_filtered <- values$data[as.numeric(input$positions)]
    
    values$data_filtered <- lapply(data_filtered, function(x) {
      subset(x, recordType %in% input$recordTypes)
    })
                                   
  })
  
  ## --------------------- OUTPUT ------------------------------------------- ##
  output$results <- renderText({
    if (is.null(values$data))
      return(NULL)
    
    paste("Positions:", values$positions, "\n",
          "Record Types:", paste(values$types, collapse = ","))
    
    
  })
  
  output$main_plot <- renderPlot({
    
    # # be reactive to...
    input$recordTypes
    input$positions
    
    if (is.null(values$data_filtered)) {
      plot(0, type = "n", axes = FALSE, ann = FALSE)
      return(NULL)
    }
    
    plot(values$data_filtered, combine = TRUE)
    
  })
  
}##EndOf::function(input, output)