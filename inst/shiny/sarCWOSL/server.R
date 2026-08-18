function(input, output, session) {
  options(shiny.maxRequestSize = 30 * 1024^2) # 30MB upload limit


# 1. Default input data ---------------------------------------------------
  # If a data set "startData" exists in the global environment use it,
  # otherwise fall back to the bundled example data set.
  if ("startData" %in% names(.GlobalEnv)) {
    data <- startData
  } else {
    object <- Luminescence::Risoe.BINfileData2RLum.Analysis(CWOSL.SAR.Data, pos = 1:2)
  }


# 2. Reactive state -------------------------------------------------------
  # Central store for all data and analysis state that is shared between
  # observers/renders and mutated by the user across the session.
  values <- reactiveValues(
    data_primary = object,
    data_filtered = NULL,
    curve_table = NULL,
    uids = NULL,
    file_extension = NULL,
    args = NULL,
    results = list(),
    ## full RLum.Results from analyse_SAR.CWOSL(plot=FALSE);
    ## patched in-place when the user edits the LxTx table
    sar_result = NULL,
    ## unmodified baseline result (used by the Reset button)
    sar_result_base = NULL,
    ## plot-only args captured at analysis time so output$main_plot
    ## does not need to read values$args (avoids double render)
    sar_plot_args = list(),
    ## freshly computed LxTx table (reset on every args change)
    lxtx_table = NULL,
    ## the table actually shown in output$lxtx_hot; updated on
    ## position/settings changes and on Reset, but NOT on user
    ## edits (so rhandsontable never re-renders mid-edit)
    lxtx_active_table = NULL,
    ## per-position user edits; keyed by position index string;
    ## persist for the lifetime of the session
    lxtx_edits = list(),
    ## track the last position to detect position changes
    ## (so we only reset lxtx_active_table on position switch,
    ## not on every args change like signal_integral)
    lxtx_last_position = NULL,
    ## signature of the analysis inputs the current sar_result
    ## was computed from; used to skip redundant re-analysis
    last_args_object = NULL,
    last_args_signal_integral = NULL,
    last_args_background = NULL,
    last_args_mode = NULL,
    last_args_fit_method = NULL,
    last_args_fit_options = NULL,
    last_args_criteria = NULL,
    ## row of the curve table currently shown in the
    ## interactive plot; defaults to the first curve
    selected_curve_row = 1)

# 3. Core helpers ---------------------------------------------------------
  # Small, self-contained functions used across several sections below.

  ## extract the unique curve identifiers of an RLum.Analysis object
  get_uids <- function(data) {
    vapply(data@records, function(x) x@.uid, character(1))
  }

  ## filter the currently selected position down to the given record types,
  ## dropping internal XSYG curves (those whose record type starts with "_")
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

  ## build the data.frame shown in the rhandsontable used to
  ## (de)select individual curves of the currently selected position
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
      TYPE = vapply(records, function(x) x@recordType, character(1)),
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


# 4. Random seed handling -------------------------------------------------
  ## fixed random seed (NULL when not fixing the seed)
  fixed_seed <- reactiveVal(NULL)

  ## return the seed to use, or NULL if the seed is not fixed
  get_seed <- function() {
    if (isTRUE(input$fix_seed) && !is.null(fixed_seed()))
      fixed_seed()
    else
      NULL
  }

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


# 5. Rejection criteria ---------------------------------------------------
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


# # 6. Aliquot status indicators ------------------------------------------
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


# 7. Data import ----------------------------------------------------------
  # Read in the uploaded XSYG/BIN/BINX file (DATA SET 1).
  observeEvent(input$file, {
    inFile <- input$file
    if (is.null(inFile))
      return(NULL) # if no file was uploaded return NULL

    values$file_extension <- tolower(tools::file_ext(inFile$name))
    values$data_primary <- switch(
      values$file_extension,
      "xsyg" = Luminescence::read_XSYG2R(
        file = inFile$datapath,
        fastForward = TRUE,
        verbose = FALSE),
      "bin" = Luminescence::read_BIN2R(
        file = inFile$datapath,
        fastForward = TRUE,
        verbose = FALSE),
      "binx" = Luminescence::read_BIN2R(
        file = inFile$datapath,
        fastForward = TRUE,
        verbose = FALSE))

    ## ensure results are reset when a new file is loaded
    values$results <- list()
    values$data_filtered <- NULL

    ## reset per-position LxTx edits and related state so edits made on the
    ## previously loaded file are not carried over to the new file
    values$lxtx_edits <- list()
    values$lxtx_active_table <- NULL
    values$lxtx_last_position <- NULL

    ## The only way to identify curves in an RLum.Analysis object is by
    ## using their uids. Therefore, we keep the list of uids in the primary
    ## data, which is updated when the selected position is changed.
    ## This allows us to keep the curve checkboxes reflect which curves are
    ## selected/deselected.
    values$uids <- get_uids(values$data_primary[[1]])

    RLumShiny:::tryNotify(valid.records <- Luminescence::get_RLum(
      object = values$data_primary[[1]], recordType = c("^OSL", "^IRSL")))
    if (length(valid.records) == 0) {
      return(NULL)
    }
    max.channels <- max(vapply(valid.records, nrow, FUN.VALUE = numeric(1)))
    updateSliderInput(
      session, "background_integral",
      value = c(max(max.channels - 100, 10), max.channels),
      max = max.channels)
  })


# 8. Curve selection & inspection -----------------------------------------
  # Position and record-type controls, the (de)select-curves table, and the
  # interactive single-curve plot.

  ## (re)build the filtered data and curve table when the position changes
  observeEvent(input$positions, {
    values$data_filtered <- make_selection(input$positions, input$recordTypes)
    values$uids <- get_uids(values$data_primary[[as.integer(input$positions)]])
    values$curve_table <- make_curve_table()
    values$selected_curve_row <- 1
  })

  ## (re)build the filtered data and curve table when the record types change
  observeEvent(input$recordTypes, {
    values$data_filtered <- make_selection(input$positions, input$recordTypes)
    values$curve_table <- make_curve_table()
    values$selected_curve_row <- 1
  })

  ## The rhandsontable is (re)rendered whenever a new file is loaded or the
  ## currently selected position/record types change. Its "SEL" column takes
  ## over the role previously fulfilled by the curve checkboxes: only the
  ## curves with SEL == TRUE are kept in the filtered object.
  observeEvent(input$curves, {
    ## Skip programmatic re-renders (e.g. triggered by a position switch).
    ## rhandsontable reports a load/reload as an "afterChange" event with
    ## changes == NULL (there are no real cell edits), so the data was already
    ## computed by the position/record-type observer. Recomputing here would
    ## replace values$data_filtered with a distinct object and make the main
    ## analysis observer's identity guard fail, running analyse_SAR twice.
    chg <- input$curves$changes
    if (is.null(chg) || is.null(chg$event) || is.null(chg$changes))
      return(NULL)

    res <- RLumShiny:::rhandsontable_workaround(input$curves)
    if (is.null(res))
      return(NULL)

    values$curve_table <- res

    selected.idx <- which(res$SEL)
    if (length(selected.idx) == 0) {
      values$data_filtered <- NULL
    } else {
      pos <- as.integer(input$positions)
      values$data_filtered <- Luminescence::get_RLum(
        object = values$data_primary[pos],
        record.id = selected.idx,
        drop = FALSE)
    }
  })

  ## prev/next buttons and direct numeric entry to select the position
  output$positions <- renderUI({
    values$all_positions <- RLumShiny:::get_unique_positions(values$data_primary)
    n <- length(values$all_positions)
    div(
      ## prev/next buttons pinned to the slider edges, numeric input centered
      ## between them; the input shares the button height
      div(class = "positions-row",
          actionButton("pos_prev", icon("arrow-left", lib = "font-awesome"),
                       style = "padding: 0;"),
          div(id = "positions_direct_wrapper",
              numericInput("positions_direct", NULL,
                           value = 1, min = 1, max = max(n, 1), step = 1,
                           width = "80px"),
              style = "flex: 0 0 auto; margin: 0 8px; text-align: center; display: flex; align-items: center;"
          ),
          actionButton("pos_next", icon("arrow-right", lib = "font-awesome"),
                       style = "padding: 0;")
      ),
      sliderInput("positions", "",
                  min = 1, max = max(n, 1), value = 1, step = 1,
                  ticks = FALSE, width = "100%"),
      hr()
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

  ## record-type checkboxes
  output$recordTypes <- renderUI({
    types <- sort(RLumShiny:::get_unique_types(values$data_primary))
    checkboxGroupInput("recordTypes", "Select record types",
                       choices = types,
                       selected = types,
                       inline = TRUE)
  })

  ## (de)select individual curves via an editable table
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
  ## interactive plotly plot; until the first click the first curve is shown
  observeEvent(input$curves_select, {
    if (!is.null(input$curves_select$select$r))
      values$selected_curve_row <- input$curves_select$select$r
  })

  output$curve_plot <- plotly::renderPlotly({
    req(input$positions)
    pos <- as.integer(input$positions)
    if (pos > length(values$data_primary))
      return(NULL)

    row <- values$selected_curve_row
    ## fall back to the first curve if the stored row is not selectable
    if (is.null(row) || row < 1 ||
        row > length(values$data_primary[[pos]]@records))
      row <- 1
    curve <- values$data_primary[[pos]]@records[[row]]

    ## combine the two log checkboxes into plot_RLum.Data.Curve's log argument
    log_axis <- paste0(ifelse(input$curve_logx, "x", ""),
                       ifelse(input$curve_logy, "y", ""))

    p <- Luminescence::plot_RLum.Data.Curve(
      object = curve,
      log = log_axis,
      norm = input$curve_norm,
      interactive = TRUE,
      .shiny = TRUE) |>
      layout(
        plot_bgcolor  = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)"
      )
    p
  })


# 9. Analysis pipeline ----------------------------------------------------
  # Assemble the analysis arguments, keep the background integral from
  # overlapping the signal integral, and run analyse_SAR.CWOSL(plot = FALSE)
  # once per genuine change. Also handles the "Analyze all" / "Clear results"
  # batch actions.

  ## collect all analyse_SAR.CWOSL(), fit_DoseResponseCurve() and plotting
  ## arguments from the current input values into a single args list
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
      fit.force_through_origin = input$fit_force_through_origin,
      fit.weights = input$fit_weights,
      n.MC = input$n_MC,
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

  ## background integral cannot overlap with signal integral
  observeEvent(input$signal_integral, {
    updateSliderInput(inputId = "background_integral",
                      min = max(input$signal_integral) + 1)
  })

  ## Single observer that runs analyse_SAR.CWOSL(plot = FALSE) once per genuine
  ## position/settings change.  It stores the full RLum.Results object so
  ## output$main_plot can call .plot_SAR.CWOSL() directly, and extracts the
  ## LxTx table for the editable rhandsontable below the plot.
  observe({
    req(values$args)

    ## Content-based guard: values$args is rebuilt as a fresh list() object on
    ## every relevant input change, and some of those rebuilds leave the actual
    ## analysis inputs identical (e.g. a re-render of the hot tables).  The main
    ## observer therefore fires on every rebuild, causing analyse_SAR.CWOSL to
    ## run repeatedly.  We compare a compact signature of the analysis-relevant
    ## inputs and skip re-analysis when nothing meaningful has changed.
    full_args       <- values$args
    full_args$plot  <- FALSE
    sig <- c(
      object           = identical(full_args$object, values$last_args_object),
      signal_integral  = identical(full_args$signal_integral,
                                   values$last_args_signal_integral),
      background       = identical(full_args$background_integral,
                                   values$last_args_background),
      mode             = identical(full_args$mode, values$last_args_mode),
      fit_method       = identical(full_args[["fit.method"]],
                                   values$last_args_fit_method),
      fit_options      = identical(
        list(
          force_through_origin = full_args[["fit.force_through_origin"]],
          weights             = full_args[["fit.weights"]],
          n.MC                = full_args[["n.MC"]]
        ),
        values$last_args_fit_options),
      criteria         = identical(full_args$rejection.criteria,
                                   values$last_args_criteria)
    )
    if (all(sig)) return(NULL)

    ## Record the signature that this analysis was computed from.
    values$last_args_object           <- full_args$object
    values$last_args_signal_integral  <- full_args$signal_integral
    values$last_args_background       <- full_args$background_integral
    values$last_args_mode             <- full_args$mode
    values$last_args_fit_method       <- full_args[["fit.method"]]
    values$last_args_fit_options      <- list(
      force_through_origin = full_args[["fit.force_through_origin"]],
      weights             = full_args[["fit.weights"]],
      n.MC                = full_args[["n.MC"]]
    )
    values$last_args_criteria         <- full_args$rejection.criteria

    seed <- get_seed()
    if (!is.null(seed)) set.seed(seed)

    full_result <- RLumShiny:::tryNotify(do.call(analyse_SAR.CWOSL, full_args))
    if (!inherits(full_result, "RLum.Results")) return(NULL)

    ## Store both the live result (may later be patched by user edits) and the
    ## unmodified baseline (used to restore on Reset).
    values$sar_result      <- full_result
    values$sar_result_base <- full_result

    ## Capture plot-only arguments once so output$main_plot does not depend on
    ## values$args (which would cause an unnecessary double render).
    plot_arg_names <- c("legend", "legend.pos", "density_rug", "log", "main", "cex")
    values$sar_plot_args <- Filter(
      Negate(is.null),
      values$args[intersect(names(values$args), plot_arg_names)]
    )

    ## Persist results per position for the summary tables.
    for (pos in full_result$data$POS) {
      if (is.na(pos)) next()
      idx <- match(pos, values$all_positions)
      isolate(values$results[[idx]] <- full_result$data[full_result$data$POS == pos, ])
    }

    ## Extract the LxTx table for the rhandsontable.
    tbl <- Luminescence::get_RLum(full_result, data.object = "LnLxTnTx.table")
    tbl <- tbl[, setdiff(colnames(tbl), "UID"), drop = FALSE]
    values$lxtx_table <- tbl

    ## Restore the stored edits for the current position (if any) so that both
    ## the table widget and the plot reflect them.  This runs after any fresh
    ## analysis of the current position - on a position change AND on a settings
    ## change that re-analyses the same position (e.g. changing signal_integral).
    current_pos <- isolate(as.integer(input$positions))
    pos_key <- as.character(current_pos)
    stored_edits <- isolate(values$lxtx_edits[[pos_key]])

    ## Only reset lxtx_active_table when the position actually changes;
    ## on a settings change for the same position the widget already holds the edits.
    if (is.null(values$lxtx_last_position) || values$lxtx_last_position != current_pos) {
      values$lxtx_active_table <- stored_edits %||% tbl
      values$lxtx_last_position <- current_pos
    }

    ## If there are stored edits for this position, apply them to the freshly
    ## computed sar_result so the plot reflects them (regardless of whether the
    ## position changed or only the settings did).
    if (!is.null(stored_edits)) {
        lxtx_full <- full_result@data$LnLxTnTx.table
        for (col in intersect(colnames(stored_edits), colnames(lxtx_full)))
        lxtx_full[[col]] <- stored_edits[[col]]
        full_result@data$LnLxTnTx.table <- lxtx_full

        ## Refit the DRC with the stored edits.
        fit_result_restored <- tryCatch(
          fit_DoseResponseCurve(
            object = data.frame(
              Dose = stored_edits$Dose,
              LxTx = stored_edits$LxTx,
              LxTx.Error = stored_edits$LxTx.Error),
            mode = values$args$mode %||% "interpolation",
            fit.method = values$args[["fit.method"]] %||% "SSE",
            fit.force_through_origin = values$args[["fit.force_through_origin"]] %||% FALSE,
            fit.weights = values$args[["fit.weights"]] %||% "inverse_var",
            n.MC = values$args[["n.MC"]] %||% 100,
            verbose = FALSE,
            txtProgressBar = FALSE
          ),
          error = function(e) NULL
        )

        if (inherits(fit_result_restored, "RLum.Results")) {
          de_data_restored <- Luminescence::get_RLum(fit_result_restored)
          full_result@data$.plot.data[[1]]$GC.fit <- fit_result_restored
          de_cols <- intersect(c("De", "De.Error", ".De.plot", ".De.raw"),
                               colnames(de_data_restored))
          for (col in de_cols)
            full_result@data$data[[col]] <- de_data_restored[[col]][1]
        }

        values$sar_result <- full_result
    }
  })

  ## output$main_plot only reads values$sar_result (and the captured plot args).
  ## Whenever the observer above or the LxTx-edit observer patches sar_result,
  ## this render fires automatically and redraws the full SAR plot.
  output$main_plot <- renderPlot({
    req(values$sar_result)
    seed <- get_seed()
    if (!is.null(seed)) set.seed(seed)

    do.call(Luminescence:::.plot_SAR.CWOSL,
            c(list(results      = values$sar_result,
                   plot_onePage = TRUE),
              isolate(values$sar_plot_args)))
  })

  ## batch run over all positions
  observeEvent(input$analyze_all, {
    req(input$positions)
    seed <- get_seed()
    if (!is.null(seed)) set.seed(seed)

    ## Use a local copy so values$args is never mutated (which would retrigger
    ## the main observer and cause an unnecessary single-position re-analysis).
    all_args        <- values$args
    all_args$object <- values$data_primary
    all_args$plot   <- FALSE

    results <- RLumShiny:::tryNotify(do.call(analyse_SAR.CWOSL, all_args))

    ## store the results obtained for each position
    if (inherits(results, "RLum.Results")) {
      for (pos in results$data$POS) {
        if (is.na(pos)) next()
        idx <- match(pos, values$all_positions)
        values$results[[idx]] <- results$data[results$data$POS == pos, ]
      }
    }
  })

  ## clear all stored results and reset the calculation
  observeEvent(input$clear_results, {
    values$results <- list()
  })



# 10. LxTx table editing --------------------------------------------------
  # Render the editable LxTx table below the main plot, apply user edits
  # (persisting them, refitting the DRC and patching sar_result), and the
  # Reset button that restores the freshly computed values.

  ## Step 2: render the LxTx table as an editable rhandsontable.
  ## Renders from lxtx_active_table only - NOT from lxtx_edits directly -
  ## so that user edits do not cause a re-render (which would reset scroll
  ## position and selected cell).  Vertical scrollbar beyond 10 rows;
  ## horizontal scrollbar beyond 8 columns (stretchH = "none").
  output$lxtx_hot <- rhandsontable::renderRHandsontable({
    req(values$lxtx_active_table)
    tbl <- values$lxtx_active_table

    row_px    <- 23L
    header_px <- 30L
    height <- if (nrow(tbl) > 10L) 10L * row_px + header_px else NULL

    rhandsontable::rhandsontable(tbl,
                                 rowHeaders  = NULL,
                                 height      = height,
                                 stretchH    = "none") |>
      rhandsontable::hot_col("Name",     readOnly = TRUE) |>
      rhandsontable::hot_col("Repeated", readOnly = TRUE) |>
      rhandsontable::hot_table(highlightRow = TRUE)
  })

  ## Step 3: when the user edits a cell, persist the change, refit the DRC,
  ## and patch values$sar_result so the main plot re-renders automatically.
  ## "afterLoadData" events (programmatic re-renders) are skipped to avoid loops.
  observeEvent(input$lxtx_hot, {
    event <- input$lxtx_hot$changes$event
    if (is.null(event) || event == "afterLoadData") return(NULL)

    res <- RLumShiny:::rhandsontable_workaround(input$lxtx_hot)
    if (is.null(res)) return(NULL)

    ## Persist edits for this position for the rest of the session.
    pos_key <- as.character(as.integer(input$positions))
    values$lxtx_edits[[pos_key]] <- res

    ## Refit the dose-response curve with the (possibly modified) LxTx values.
    fit_result <- tryCatch(
      fit_DoseResponseCurve(
        object         = data.frame(Dose = res$Dose,
                                    LxTx = res$LxTx,
                                    LxTx.Error = res$LxTx.Error),
        mode           = values$args$mode %||% "interpolation",
        fit.method     = values$args[["fit.method"]] %||% "SSE",
        fit.force_through_origin = values$args[["fit.force_through_origin"]] %||% FALSE,
        fit.weights    = values$args[["fit.weights"]] %||% "inverse_var",
        n.MC           = values$args[["n.MC"]] %||% 100,
        verbose        = FALSE,
        txtProgressBar = FALSE
      ),
      error = function(e) NULL
    )
    if (!inherits(fit_result, "RLum.Results")) return(NULL)

    de_data <- Luminescence::get_RLum(fit_result)

    ## Patch the stored RLum.Results object in-place so the plot re-renders.
    sar <- isolate(values$sar_result)
    if (is.null(sar)) return(NULL)

    ## Overwrite the LnLxTnTx.table with the user's edited values.
    lxtx_full <- sar@data$LnLxTnTx.table
    for (col in intersect(colnames(res), colnames(lxtx_full)))
      lxtx_full[[col]] <- res[[col]]
    sar@data$LnLxTnTx.table <- lxtx_full

    ## Replace the dose-response curve fit (drives the DRC panel in the plot).
    ## .plot.data is a list-of-lists when object was passed as a list, so [[1]].
    sar@data$.plot.data[[1]]$GC.fit <- fit_result

    ## Update the De summary columns used by the Checks panel and results tables.
    de_cols <- intersect(c("De", "De.Error", ".De.plot", ".De.raw"),
                         colnames(de_data))
    for (col in de_cols)
      sar@data$data[[col]] <- de_data[[col]][1]

    ## Writing sar_result triggers output$main_plot to re-render.
    values$sar_result <- sar

    ## Also update values$results so the Results / Highlights tabs stay in sync.
    pos <- as.integer(input$positions)
    idx <- match(pos, values$all_positions)
    current_result <- isolate(values$results[[idx]])
    if (!is.null(current_result) && all(c("De", "De.Error") %in% colnames(de_data))) {
      current_result$De       <- de_data$De[1]
      current_result$De.Error <- de_data$De.Error[1]
      isolate(values$results[[idx]] <- current_result)
    }
  })

  ## Reset button: discard stored edits for the current position, restore the
  ## freshly computed LxTx table and the unmodified RLum.Results object.
  observeEvent(input$lxtx_reset, {
    req(input$positions, values$lxtx_table, values$sar_result_base)
    pos_key <- as.character(as.integer(input$positions))
    values$lxtx_edits[[pos_key]]  <- NULL
    values$lxtx_active_table      <- values$lxtx_table
    values$sar_result              <- values$sar_result_base
  })


# 11. Results, Highlights & Abanico plot ----------------------------------
  ## build the combined results table shown in the Results / Highlights tabs
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
    num.idx <- vapply(data, is.numeric, logical(1))
    data[num.idx] <- lapply(data[num.idx], round, digits = 3)

    data
  }

  output$results <- DT::renderDT({
    getResultsTable()
  }, options = list(pageLength = 10, scrollX = TRUE))

  output$highlights <- DT::renderDT({
    getResultsTable(onlyHighlights = TRUE)
  }, options = list(pageLength = 10))

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
    res <- Luminescence::plot_AbanicoPlot(
      data = df[c("De", "De.Error")],
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


# 12. Code export ---------------------------------------------------------
  # Build the reproducible R code shown on the "R code" tab and wire up the
  # export handlers (code and plot).
  observe({
    # nested renderText({}) for code output on "R plot code" tab
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 1,
                              extension = values$file_extension %||% "csv",
                              list(name = "analyse_SAR.CWOSL",
                                   arg1 = "object = data",
                                   args = values$args))

    output$plotCode <- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "analyse_SAR.CWOSL", args = values$args)
  })


# 13. Session lifecycle ---------------------------------------------------
  session$onSessionEnded(function() {
    stopApp()
  })
}##EndOf::function(input, output)
