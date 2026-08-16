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

  ## overall RC.Status of a stored result for a given position index, or NULL
  ## when no result has been stored (yet). A position is considered FAILED as
  ## soon as any of its aliquots failed.
  get_position_status <- function(idx) {
    if (idx < 1 || idx > length(values$results))
      return(NULL)
    res <- values$results[[idx]]
    if (is.null(res) || nrow(res) == 0 || !"RC.Status" %in% colnames(res))
      return(NULL)
    st <- res$RC.Status[!is.na(res$RC.Status)]
    if (length(st) == 0)
      return(NULL)
    if (any(toupper(st) == "FAILED"))
      "FAILED" else "OK"
  }

  ## build a small coloured clickable circle showing the aliquot status for the
  ## bottom status bar; coloured by RC.Status (light green for OK, light red
  ## for FAILED, grey when no result yet) with just the aliquot number inside.
  ## Clicking a circle jumps to that aliquot/position.
  aliquot_dot <- function(idx, status, selected = FALSE) {
    cls <- if (is.null(status) || is.na(status)) "aliquot-none" else
      if (status == "OK") "aliquot-ok" else "aliquot-fail"
    if (selected) cls <- paste(cls, "aliquot-selected")
    tags$span(
      class = paste("aliquot-btn", cls),
      `data-aliquot` = idx,
      onclick = sprintf("Shiny.setInputValue('aliquot_jump', %d, {priority: 'event'});",
                        idx),
      idx
    )
  }

  ## build a coloured aliquot status button for the currently selected aliquot;
  ## coloured by RC.Status with an OK/Failed icon and an "Aliquot: #n" label
  aliquot_button <- function(idx, status) {
    cls <- if (is.null(status) || is.na(status)) "aliquot-none" else
      if (status == "OK") "aliquot-ok" else "aliquot-fail"
    icon_name <- if (is.null(status) || is.na(status)) "circle-question" else
      if (status == "OK") "circle-check" else "circle-xmark"
    tags$span(
      class = paste("aliquot-btn-current", cls),
      icon(icon_name),
      paste0("Aliquot: #", idx)
    )
  }

  ## coloured button for the currently selected aliquot/position, shown right
  ## below the data import field
  output$currentAliquot <- renderUI({
    req(values$all_positions, input$positions)
    pos <- as.integer(input$positions)
    if (length(pos) != 1 || is.na(pos) || pos > length(values$all_positions))
      return(NULL)
    div(class = "current-aliquot",
        aliquot_button(pos, get_position_status(pos)))
  })

  ## full-width gray bar at the bottom of the sidebar showing the status of
  ## every aliquot/position
  output$aliquotBar <- renderUI({
    req(values$all_positions, input$positions)
    n <- length(values$all_positions)
    cur <- as.integer(input$positions)
    btns <- lapply(seq_len(n), function(i)
      aliquot_dot(i, get_position_status(i), selected = (i == cur)))
    div(class = "aliquot-bar", btns)
  })

  ## clicking an aliquot circle in the status bar jumps to that position
  observeEvent(input$aliquot_jump, {
    req(values$all_positions, input$positions)
    n <- length(values$all_positions)
    val <- min(max(as.integer(input$aliquot_jump), 1), n)
    if (val != as.integer(input$positions))
      updateSliderInput(session, "positions", value = val)
  })


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

  ## fixed random seed (NULL when not fixing the seed)
  fixed_seed <- reactiveVal(NULL)

  ## when the "Fix random seed" box is checked, generate a seed once (via
  ## runif) and keep it until the box is checked again; when unchecked, clear it
  observeEvent(input$fix_seed, {
    if (isTRUE(input$fix_seed)) {
      seed <- round(runif(1, 0, 10000))
      fixed_seed(seed)
      updateNumericInput(session, "seed_value", value = seed)
    } else {
      fixed_seed(NULL)
    }
  })

  ## a user-entered seed in the Method panel overrides the generated one, but
  ## only takes effect while the box is checked
  observeEvent(input$seed_value, {
    if (isTRUE(input$fix_seed) && !is.na(input$seed_value))
      fixed_seed(input$seed_value)
  })

  ## return the seed to use, or NULL if the seed is not fixed
  get_seed <- function() {
    if (isTRUE(input$fix_seed) && !is.null(fixed_seed()))
      fixed_seed()
    else
      NULL
  }

  ## default rejection criteria as used by analyse_SAR.CWOSL()
  rejection_defaults <- list(
    recycling.ratio = 10,
    recuperation.rate = 10,
    palaeodose.error = 10,
    testdose.error = 10,
    sn.ratio = NA_real_,
    exceed.max.regpoint = FALSE,
    consider.uncertainties = FALSE,
    recuperation_reference = "Natural",
    sn_reference = "Natural"
  )

  ## rejection criteria currently applied (defaults at start, replaced by the
  ## user via the "Apply rejection criteria" button)
  active_criteria <- reactiveVal(rejection_defaults)

  ## classify the type of a rejection criterion value
  rejection_type <- function(x) {
    if (is.logical(x)) "logical" else if (is.numeric(x)) "numeric" else "character"
  }

  ## valid reference names (e.g. "Natural", "R1", "R2") derived from the dose
  ## points of the Lx curves of the currently selected position. Mirrors the
  ## naming scheme used by analyse_SAR.CWOSL().
  get_reference_labels <- function() {
    pos <- as.integer(input$positions)
    if (is.null(values$data_primary) || is.na(pos) ||
        pos > length(values$data_primary))
      return(c("Natural"))

    recs <- values$data_primary[[pos]]@records
    is_osl <- vapply(recs, function(r)
      grepl("^(OSL|IRSL)", r@recordType, ignore.case = TRUE), logical(1))
    ## Lx curves are the odd-indexed OSL/IRSL records of each LxTx pair
    lx_recs <- recs[is_osl][c(TRUE, FALSE)]
    dose <- sapply(lx_recs, function(r) r@info$IRR_TIME %||% NA)
    if (length(dose) == 0)
      return(c("Natural"))

    dose_names <- paste0("R", seq_along(dose) - 1)
    zero_id <- which(dose == 0)
    dose_names[zero_id] <- "R0"
    if (length(zero_id))
      dose_names[zero_id[1]] <- "Natural"
    unique(dose_names)
  }

  ## build a native, type-appropriate input widget for each criterion so the
  ## user gets a checkbox (logical), numeric field (numeric), dropdown for the
  ## reference criteria or a free text field (character)
  output$rejection_criteria <- renderUI({
    crit <- active_criteria()
    is_reference <- names(crit) %in% c("recuperation_reference", "sn_reference")
    ref_choices <- get_reference_labels()
    inputs <- lapply(names(crit), function(nm) {
      val <- crit[[nm]]
      input_id <- paste0("crit_", nm)
      widget <- switch(
        rejection_type(val),
        logical = checkboxInput(input_id, NULL, value = isTRUE(val)),
        numeric = numericInput(input_id, NULL, value = val,
                               min = 0, step = 1),
        character = if (is_reference[match(nm, names(crit))])
          selectInput(input_id, NULL,
                      choices = ref_choices,
                      selected = as.character(val))
        else
          textInput(input_id, NULL, value = as.character(val))
      )
      fluidRow(
        column(width = 7, tags$label(class = "control-label", nm)),
        column(width = 5, widget)
      )
    })
    do.call(tagList, inputs)
  })

  ## apply the user-edited rejection criteria
  observeEvent(input$apply_criteria, {
    crit <- list()
    for (nm in names(active_criteria())) {
      val <- input[[paste0("crit_", nm)]]
      crit[[nm]] <- switch(
        rejection_type(active_criteria()[[nm]]),
        logical = isTRUE(val),
        numeric = if (is.null(val) || is.na(val)) NA_real_ else as.numeric(val),
        character = as.character(val)
      )
    }
    active_criteria(crit)
  })

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
      rejection.criteria = active_criteria(),
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
      column(width = 8,
             sliderInput("positions", "Positions",
                         min = 1, max = max(n, 1), value = 1, step = 1,
                         ticks = FALSE)
      ),
      column(width = 1, align = "center",
             actionButton("pos_next", icon("chevron-right"),
                          style = "padding: 6px;")
      ),
      column(width = 2,
             numericInput("positions_direct", NULL,
                          value = 1, min = 1, max = max(n, 1), step = 1,
                          width = "100%")
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

  ## keep the direct position entry in sync with the slider (e.g. arrow clicks)
  observeEvent(input$positions, {
    req(input$positions_direct)
    val <- as.integer(input$positions)
    if (!is.na(val) && val != input$positions_direct)
      updateNumericInput(session, "positions_direct", value = val)
  })

  ## selecting a position by typing it directly; restrict to existing positions
  observeEvent(input$positions_direct, {
    req(input$positions)
    n <- length(values$all_positions)
    val <- as.integer(input$positions_direct)
    if (is.na(val)) {
      updateNumericInput(session, "positions_direct", value = input$positions)
      return(NULL)
    }
    ## clamp to the range of existing positions
    val <- min(max(val, 1), n)
    updateNumericInput(session, "positions_direct", value = val)
    if (val != as.integer(input$positions))
      updateSliderInput(session, "positions", value = val)
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

    row <- input$curves_select$select$r
    curve <- values$data_primary[[pos]]@records[[row]]
    p <- Luminescence::plot_RLum.Data.Curve(
      object = curve,

      interactive = TRUE,
      .shiny = TRUE) |>
      layout(
        plot_bgcolor  = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)"
      )
    p
  })

  observeEvent(input$analyze_all, {
    req(input$positions)
    seed <- get_seed()
    if (!is.null(seed)) set.seed(seed)
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

  ## clear all stored results and reset the calculation
  observeEvent(input$clear_results, {
    values$results <- list()
  })

  output$main_plot <- renderPlot({
    req(input$positions)
    req(values$args)
    seed <- get_seed()
    if (!is.null(seed)) set.seed(seed)
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

    seed <- get_seed()
    if (!is.null(seed)) set.seed(seed)
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
