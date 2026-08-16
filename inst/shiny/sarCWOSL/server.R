## Server.R
## MAIN FUNCTION
function(input, output, session) {
  options(shiny.maxRequestSize = 30 * 1024^2) # 30MB upload limit

  make_selection <- function(positions, recordTypes) {
    ## remove internal XSYG curves
    recordTypes <- grepv("^_", recordTypes, invert = TRUE)
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

  get_uids <- function(data) {
    sapply(data@records, function(x) x@.uid)
  }

  # build the data.frame shown in the rhandsontable used to
  # (de)select individual curves of the currently selected position
  make_curve_table <- function() {
    pos <- as.integer(input$positions)
    if (is.na(pos) || pos > length(values$data_primary))
      return(NULL)

    records <- values$data_primary[[pos]]@records

    ## a curve is selected if it is still present in the filtered object
    if (is.null(values$data_filtered)) {
      selected <- seq_along(records) %in% numeric(0)
    } else {
      kept.uids <- tryCatch(get_uids(values$data_filtered[[1]]),
                            error = function(e) NULL)
      if (is.null(kept.uids)) {
        selected <- rep(TRUE, length(records))
      } else {
        selected <- get_uids(values$data_primary[[pos]]) %in% kept.uids
      }
    }

    data.frame(
      ID = seq_along(records),
      SEL = selected,
      TYPE = sapply(records, function(x) x@recordType),
      stringsAsFactors = FALSE
    )
  }

  # input data (with default)
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    object <- Risoe.BINfileData2RLum.Analysis(CWOSL.SAR.Data, pos = 1:2)
  }

  values <- reactiveValues(data_primary = object,
                           data_filtered = NULL,
                           curve_table = NULL,
                           uids = NULL,
                           file_extension = NULL,
                           args = NULL,
                           results = list())

  session$onSessionEnded(function() {
    stopApp()
  })

  # check and read in file (DATA SET 1)
  observeEvent(input$file, {
    inFile <- input$file
    if(is.null(inFile))
      return(NULL) # if no file was uploaded return NULL

    values$file_extension <- tolower(tools::file_ext(inFile$name))
    values$data_primary <- switch(values$file_extension,
                                  "xsyg" = read_XSYG2R(inFile$datapath,
                                                       fastForward = TRUE,
                                                       verbose = FALSE),
                                  "bin" = read_BIN2R(inFile$datapath,
                                                     fastForward = TRUE,
                                                     verbose = FALSE),
                                  "binx" = read_BIN2R(inFile$datapath,
                                                       fastForward = TRUE,
                                                       verbose = FALSE)
                                  )

    ## ensure results are reset when a new file is loaded
    values$results <- list()
    values$data_filtered <- NULL

    ## The only way to identify curves in an RLum.Analysis object is by
    ## using their uids. Therefore, we keep the list of uids in the primary
    ## data, which is updated when the selected position is changed.
    ## This allows us to keep the curve checkboxes reflect which curves are
    ## selected/deselected.
    values$uids <- get_uids(values$data_primary[[1]])

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
    values$uids <- get_uids(values$data_primary[[as.integer(input$positions)]])
    values$curve_table <- make_curve_table()
  })

  observeEvent(input$recordTypes, {
    values$data_filtered <- make_selection(input$positions, input$recordTypes)
    values$curve_table <- make_curve_table()
  })

  ## The rhandsontable is (re)rendered whenever a new file is loaded or the
  ## currently selected position/record types change. Its "SEL" column takes
  ## over the role previously fulfilled by the curve checkboxes: only the
  ## curves with SEL == TRUE are kept in the filtered object.
  observeEvent(input$curves, {
    res <- RLumShiny:::rhandsontable_workaround(input$curves)
    if (is.null(res))
      return(NULL)

    values$curve_table <- res

    selected.idx <- which(res$SEL)
    if (length(selected.idx) == 0) {
      values$data_filtered <- NULL
    } else {
      pos <- as.integer(input$positions)
      values$data_filtered <- get_RLum(values$data_primary[pos],
                                       record.id = selected.idx,
                                       drop = FALSE)
    }
  })

  observe({
    req(input$positions)
    req(input$curves)

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
      # fit_DoseResponseCurve arguments
      mode = input$mode,
      fit.method = input$fit_method,
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
    values$all_positions <- RLumShiny:::get_unique_positions(values$data_primary)
    n <- length(values$all_positions)
    fluidRow(
      column(width = 1, align = "center",
             actionButton("pos_prev", icon("chevron-left"),
                          style = "padding: 6px;")
      ),
      column(width = 10,
             sliderInput("positions", "Positions",
                         min = 1, max = max(n, 1), value = 1, step = 1,
                         ticks = FALSE)
      ),
      column(width = 1, align = "center",
             actionButton("pos_next", icon("chevron-right"),
                          style = "padding: 6px;")
      )
    )
  })

  observeEvent(input$pos_prev, {
    updateSliderInput(session, "positions",
                      value = max(as.numeric(input$positions) - 1, 1))
  })

  observeEvent(input$pos_next, {
    updateSliderInput(session, "positions",
                      value = min(as.numeric(input$positions) + 1, length(values$all_positions)))
  })

  output$recordTypes <- renderUI({
    types <- sort(RLumShiny:::get_unique_types(values$data_primary))
    checkboxGroupInput("recordTypes", "Record types",
                       choices = types,
                       selected = types,
                       inline = TRUE)
  })

  output$curves <- renderRHandsontable({
    req(input$positions)
    req(values$curve_table)

    ## match the height of the individual curve plot window; with more rows
    ## than fit in that height the surplus is reached via a scrollbar
    height <- 320

    rhandsontable(values$curve_table,
                  height = height,
                  colHeaders = c("ID", "SEL", "TYPE"),
                  rowHeaders = NULL,
                  selectCallback = TRUE,
                  stretchH = "all",
                  width = "100%") |>
        hot_col("ID", readOnly = TRUE) |>
        hot_col("TYPE", readOnly = TRUE) |>
        hot_table(highlightRow = TRUE)
  })

  ## clicking a row in the curve table shows the corresponding curve as an
  ## interactive plotly plot
  output$curve_plot <- plotly::renderPlotly({
    req(input$curves_select)
    req(input$positions)
    pos <- as.integer(input$positions)
    if (pos > length(values$data_primary))
      return(NULL)

    row <- input$curves_select$select$r + 1
    curve <- values$data_primary[[pos]]@records[[row]]
    p <- Luminescence::plot_RLum.Data.Curve(curve, interactive = TRUE, .shiny = TRUE) |>
      layout(
        plot_bgcolor  = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)"
      )
    p
  })

  observeEvent(input$analyze_all, {
    req(input$positions)
    set.seed(1)
    obj <- values$args$object
    values$args$object <- values$data_primary
    values$args$plot <- FALSE
    results <- RLumShiny:::tryNotify(do.call(analyse_SAR.CWOSL, values$args))

    ## store the results obtained for each position
    if (inherits(results, "RLum.Results")) {
      for (pos in results$data$POS) {
        if (is.na(pos)) next()
        idx <- match(pos, values$all_positions)
        values$results[[idx]] <- results$data[results$data$POS == pos, ]
      }
    }

    ## restore arguments
    values$args$object <- obj
    values$args$plot <- TRUE
  })

  output$main_plot <- renderPlot({
    req(input$positions)
    req(values$args)
    set.seed(1)
    results <- RLumShiny:::tryNotify(do.call(analyse_SAR.CWOSL, values$args))

    ## store the results obtained for this position
    if (inherits(results, "RLum.Results")) {
      for (pos in results$data$POS) {
        if (is.na(pos)) next()
        idx <- match(pos, values$all_positions)
        isolate(values$results[[idx]] <- results$data[results$data$POS == pos, ])
      }
    }
  })

  getResultsTable <- function(onlyHighlights = FALSE) {
    if (length(values$results) == 0)
      return(NULL)
    data <- as.data.frame(data.table::rbindlist(values$results))

    ## remove internal columns
    rm.idx <- grep("^\\.", colnames(data))
    data <- data[, -rm.idx]

    if (onlyHighlights) {
      ## remove columns for secondary model parameters
      rm.idx <- match(c("D01", "D01.ERROR", "D02", "D02.ERROR",
                        "R", "R.LOWER", "R.UPPER",
                        "Dc", "Dc.LOWER", "Dc.UPPER",
                        "D63", "D63.LOWER", "D63.UPPER",
                        "D80", "D80.LOWER", "D80.UPPER",
                        "HPDI68_L", "HPDI68_U", "HPDI95_L", "HPDI95_U",
                        "signal.range", "background.range",
                        "signal.range.Tx", "background.range.Tx", "UID"),
                      colnames(data))
      data <- data[, -rm.idx]
    }

    ## round numerical columns
    num.idx <- sapply(data, is.numeric)
    data[num.idx] <- lapply(data[num.idx], round, digits = 3)

    data
  }

  output$results <- DT::renderDT({
    getResultsTable()
  }, options = list(pageLength = 10, scrollX = TRUE))

  output$highlights <- DT::renderDT({
    getResultsTable(onlyHighlights = TRUE)
  }, options = list(pageLength = 10))

  ## results table shown in the main panel below the SAR plot
  output$results_main <- DT::renderDT({
    getResultsTable()
  }, options = list(
    pageLength = 5,
    lengthChange = FALSE,
    scrollX = TRUE,
    scrollY = TRUE,
    searching = FALSE))

  ## Abanico plot of the De distribution (De and De.Error columns)
  output$abanico_plot <- renderPlot({
    req(values$results, values$all_positions, input$positions)
    if (length(values$results) == 0)
      return(NULL)

    df <- getResultsTable()
    if (is.null(df) || !all(c("De", "De.Error") %in% colnames(df)))
      return(NULL)

    keep <- !is.na(df$De) & !is.na(df$De.Error)
    df <- df[keep, ]
    ## an Abanico plot needs at least two dose values
    if (nrow(df) < 2)
      return(NULL)

    set.seed(1)
    res <- Luminescence::plot_AbanicoPlot(df[c("De", "De.Error")],
                                          zlab = expression(paste(D[e], " [s]")))

    ## mark the point belonging to the currently selected position
    if (input$abanico_mark && !is.null(res$data.global)) {
      k <- match(as.integer(input$positions), values$all_positions)
      idx <- match(k, which(keep))
      if (!is.na(idx) && idx <= nrow(res$data.global)) {
        pts <- res$data.global[idx, ]
        points(pts$precision, pts$std.estimate,
               col = "red", pch = 1, lwd = 2, cex = 2)
      }
    }

    res
  })

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 1,
                              extension = values$file_extension %||% "csv",
                              list(name = "analyse_SAR.CWOSL",
                                   arg1 = "object = data",
                                   args = values$args))

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "analyse_SAR.CWOSL", args = values$args)
  })
}##EndOf::function(input, output)
