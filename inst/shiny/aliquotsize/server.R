## Server.R
## MAIN FUNCTION
function(input, output, session) {

  # input data (with default)
  values <- reactiveValues(args = NULL)

  session$onSessionEnded(function() {
    stopApp()
  })

  observe({
    values$args <- list(
      # calc_AliquotSize arguments
      grain.size = input$grain_size,
      sample.diameter = input$sample_diameter,
      sample_carrier.diameter = input$sample_carrier_diameter,
      packing.density = input$packing_density,
      grains.counted = input$grains_counted,
      MC = input$mode == "pd",
      MC.iter = input$MC_iter,
      verbose = FALSE,
      # generic plot arguments
      main = input$main,
      xlab = input$xlab,
      col = ifelse(input$color == "custom", input$jscol1, input$color),
      line_col = ifelse(input$line_col == "custom", input$jscol2, input$line_col),
      cex = input$cex,
      rug = input$rug,
      boxplot = input$boxplot,
      summary = input$summary,
      legend = input$legend
    )
  })

  output$main_plot <- renderPlot({
    ## remove existing notifications
    removeNotification(id = "notification")

    if (input$mode == "pd") {
      values$args$packing.density <- input$packing_density
      values$args$grains.counted <- NULL
    } else {
      values$args$grains.counted <- input$grains_counted
      values$args$packing.density <- NULL
    }
    tryNotify(values$results <- do.call(calc_AliquotSize, values$args))
  })

  # Render numeric results in a data table
  output$results <- renderUI({
    res <- get_RLum(values$results)
    summary <- paste0(
        tags$b("Mean grain size (microns): "), res$grain.size, tags$br(),
        tags$b("Sample diameter (mm): "), res$sample.diameter, tags$br()
    )
    if (input$mode == "pd") {
      summary2 <- paste0(
          tags$b("Packing density: "), signif(res$packing.density, 3), tags$br(),
          tags$b("Number of grains: "), round(res$n.grains, 0)
      )
    } else {
      summary2 <- paste0(
          tags$b("Counted grains: "), res$grains.counted, tags$br(),
          tags$b("Packing density: "), signif(res$packing.density, 3)
      )
    }

    if (!is.null(values$results$MC$statistics)) {
      MC.stats <- values$results$MC$statistics
      MC.ttest <- values$results$MC$t.test
      HTML(paste0(
          summary, summary2,
          tags$h5("Monte Carlo Estimates"),
          tags$b("Number of iterations (n): "), MC.stats$n, tags$br(),
          tags$b("Median: "), round(MC.stats$median), tags$br(),
          tags$b("Mean: "), round(MC.stats$mean), tags$br(),
          tags$b("Standard deviation (mean): "), round(MC.stats$sd.abs), tags$br(),
          tags$b("Standard error (mean): "), round(MC.stats$se.abs, 1), tags$br(),
          tags$b("95% CI from t-test (mean): "), paste(round(MC.ttest$conf.int), collapse = " - "), tags$br(),
          tags$b("Standard error from CI (mean): "), round(MC.ttest$stderr, 1), tags$br()
      ))
    } else {
      HTML(summary, summary2)
    }
  })

  observe({
    # nested renderText({}) for code output on "R plot code" tab
    if (input$mode == "pd") {
      values$args$grains.counted <- NULL
    } else {
      values$args$packing.density <- NULL
    }
    code.output <- callModule(RLumShiny:::printCode, "printCode",
                              n_inputs = 0,
                              list(name = "calc_AliquotSize",
                                   args = c(dummy = NA, # the first argument is removed by printCode()
                                            values$args)))

    output$plotCode<- renderText({
      code.output
    })##EndOf::renderText({})

    callModule(RLumShiny:::exportCodeHandler, "export", code = code.output)
    callModule(RLumShiny:::exportPlotHandler, "export", fun = "calc_AliquotSize", args = values$args)
  })

}##EndOf::function(input, output)
