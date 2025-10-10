## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  values <- reactiveValues(data = NULL,
                           data_filtered = NULL,
                           positions = NULL,
                           types = NULL,
                           filename = NULL)

  session$onSessionEnded(function() {
    stopApp()
  })

  # check and read in file (DATA SET 1)
  observeEvent(input$import, {
    inFile<- input$file
    
    if(is.null(inFile)) 
      return(NULL)

    # 1. Risoe .bin(x)
    if (tools::file_ext(inFile$name) %in% c("bin", "binx")) {
      # import the file
      values$data <- read_BIN2R(inFile$datapath, fastForward = TRUE, verbose = FALSE)
      values$data_filtered <- values$data

      # set some diagnostic values
      values$positions <- unique(sapply(values$data, function(x) { x@records[[1]]@info$POSITION }))
      values$types <- unique(sapply(values$data[[1]]@records, function(x) { x@recordType }))
      values$filename <- inFile$name
    }
  })

  output$positions <- renderUI({
    if (!is.null(values$positions))
      checkboxGroupInput("positions", "Positions",
                         choiceNames = as.character(values$positions),
                         choiceValues = 1:length(values$positions),
                         selected = 1:length(values$positions),
                         inline = TRUE)
  })

  output$curveTypes <- renderUI({
    if (!is.null(values$types))
      checkboxGroupInput("curveTypes", "Curve types", 
                         choices = values$types, selected = values$types)
  })

  ## FILTER ----
  observe({
    if (is.null(values$data))
      return(NULL)
    
    data_filtered <- values$data[as.numeric(input$positions)]

    if (length(data_filtered) > 0) {
      values$data_filtered <- lapply(data_filtered, function(x) {
        subset(x, recordType %in% input$curveTypes)
      })
    }
  })
  
  ## --------------------- OUTPUT ------------------------------------------- ##
  output$positionTabs <- renderUI({
    if (is.null(values$data_filtered))
      return(NULL)
    
    tabs <- lapply(values$positions[as.numeric(input$positions)], function(pos) {
      tabPanel(pos,
               plotOutput(paste0("pos", pos))) 
    })
    do.call(tabsetPanel, c(id = "tab", tabs))
  })

  observe({
    input$tab
    values$data
    values$data_filtered
    input$curveTypes
    
    if (is.null(values$data_filtered) || length(values$data_filtered) == 0)
      return(NULL)

    pos <- which(unique(sapply(values$data_filtered,
                               function(x) {
                                 if (is.null(x)) return(-1)
                                 x@records[[1]]@info$POSITION
                               })) == input$tab)
    print(pos)

    if (length(pos) > 0) {
      choices <- 1:length(values$data_filtered[[pos]])
      updateCheckboxGroupInput(session, "curves",
                               choices = choices,
                               selected = choices,
                               inline = TRUE)
    }
  })

  output$export <- downloadHandler(
      filename = function() {
        ## write_RLum2CSV() generates multiple csv files, so we zip them up
        ext <- if (input$targetFile == "csv") "zip" else input$targetFile
        sprintf("filtered_%s.%s",
                tools::file_path_sans_ext(values$filename), ext)
      },
      content = function(file) {
        if (input$targetFile == "binx") {
          out <- convert_RLum2Risoe.BINfileData(values$data_filtered)
          write_R2BIN(out, file = file)
        } else if (input$targetFile == "csv") {
          path <- dirname(file)
          write_RLum2CSV(values$data_filtered, path = path)

          ## set the -j flag to remove the absolute paths, otherwise the zip
          ## file contains the name of the temp directory (9X are already in
          ## the default flags for utils::zip())
          utils::zip(file,
                     files = list.files(path, pattern = ".csv$", full.names = TRUE),
                     flags = "-j9X")
        }
      }
  )

  observe({
    pos_sel <- values$positions[as.numeric(input$positions)]

    for (i in 1:length(pos_sel))

      # Explanation on local({}):
      # Need local so that each item gets its own number. Without it, the value
      # of i in the renderPlot() will be the same across all instances, because
      # of when the expression is evaluated.
      # https://gist.github.com/wch/5436415/
      local({
        local_i <- i
        output[[paste0("pos", pos_sel[local_i])]] <- renderPlot({
          if (is.null(values$data_filtered[[local_i]])) {
            plot(0, type = "n", axes = FALSE, ann = FALSE)
            return(NULL)
          } else {
            plot(values$data_filtered[[local_i]],
                 combine = length(values$data_filtered[[local_i]]) > 1)
          }
        })
      })
  })

}##EndOf::function(input, output)
