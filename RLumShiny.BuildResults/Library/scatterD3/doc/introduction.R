## ---- include=FALSE-----------------------------------------------------------
library(scatterD3)
knitr::opts_chunk$set(screenshot.force = FALSE)

## ----basic, eval=FALSE--------------------------------------------------------
#  library(scatterD3)
#  scatterD3(x = mtcars$wt, y = mtcars$mpg)

## ----basic_nse----------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg)

## ----basic_cust---------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg,
          point_size = 200, point_opacity = 0.5,
          colors = "#A94175")

## ----hover_cust---------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg,
          point_size = 100, point_opacity = 0.5,
          hover_size = 4, hover_opacity = 1)

## ----cust_tooltips------------------------------------------------------------
tooltips <- paste(
  "This is an incredible <strong>", rownames(mtcars), "</strong><br />with ",
  mtcars$cyl, "cylinders !"
)
scatterD3(data = mtcars, x = wt, y = mpg, tooltip_text = tooltips)

## ----tooltips_position--------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, tooltip_position = "top left")

## ----categorical--------------------------------------------------------------
mtcars$cyl_fac <- paste(mtcars$cyl, "cylinders")
scatterD3(data = mtcars, x = cyl_fac, y = mpg)

## ----categorical_left_margin--------------------------------------------------
scatterD3(data = mtcars, x = wt, y = cyl_fac, left_margin = 80)

## ----fixed--------------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg,
          fixed = TRUE)

## ----log_scales---------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg,
          x_log = TRUE, y_log = TRUE)

## ----axis_limits--------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, xlim = c(0, 10), ylim = c(10, 35))

## ----cust_labels--------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg,
          xlab = "Weight", ylab = "Mpg")

## ----cust_labels_size---------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg,
          xlab = "Weight", ylab = "Mpg",
          axes_font_size = "160%")

## ----labels-------------------------------------------------------------------
mtcars$names <- rownames(mtcars)
scatterD3(data = mtcars, x = wt, y = mpg,
          lab = names)

## ----labels_size--------------------------------------------------------------
mtcars$names <- rownames(mtcars)
scatterD3(data = mtcars, x = wt, y = mpg,
          lab = names, labels_size = 12)

## ----labels_auto--------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, lab = names,
          labels_positions = "auto")

## ----labels_export------------------------------------------------------------
mtcars$names <- rownames(mtcars)
scatterD3(data = mtcars, x = wt, y = mpg, lab = names)

## ----labels_export_scatterD3, eval = FALSE------------------------------------
#  labels <- read.csv("scatterD3_labels.csv")
#  scatterD3(data = mtcars, x = wt, y = mpg, lab = names, labels_positions = labels)

## ----labels_export_ggplot2, eval = FALSE--------------------------------------
#  labels <- read.csv("scatterD3_labels.csv")
#  library(ggplot2)
#  ggplot() +
#    geom_point(data = mtcars, aes(x = wt, y = mpg)) +
#    geom_text(data = labels,
#              aes(x = lab_x,
#                  y = lab_y,
#                  label = lab))

## ----mapping_color------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl)

## ----map_custom_colors--------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl,
          colors = c("4" = "#ECD078", "8" = "#C02942", "6" = "#53777A"))

## ----custom_continuous_color--------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = disp, colors = "interpolatePuRd")

## ----custom_categorical_color-------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl, colors = "schemeTableau10")

## ----map_factor_levels_color--------------------------------------------------
mtcars$cyl_o <- factor(mtcars$cyl, levels = c("8", "6", "4"))
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl_o)

## ----map_continuous_color-----------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = disp)

## ----map_size-----------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, size_var = hp)

## ----map_size_range-----------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, size_var = hp,
          size_range = c(10, 1000), point_opacity = 0.7)

## ----custom_sizes-------------------------------------------------------------
scatterD3(data = mtcars, x = mpg, y = wt, size_var = cyl,
  sizes = c("4" = 10, "6" = 100, "8" = 1000))

## ----mapping------------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl, symbol_var = gear)

## ----map_factor levels--------------------------------------------------------
mtcars$cyl_o <- factor(mtcars$cyl, levels = c("8", "6", "4"))
scatterD3(data = mtcars, x = wt, y = mpg, symbol_var = cyl_o)

## ----map_custom_symbols-------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, symbol_var = cyl,
          symbols = c("4" = "wye", "8" = "star", "6" = "triangle"))

## ----opacity_var--------------------------------------------------------------
scatterD3(data = mtcars, x = mpg, y = wt, opacity_var = drat)

## ----custom_opacity-----------------------------------------------------------
scatterD3(data = mtcars, x = mpg, y = wt, opacity_var = cyl,
  opacities = c("4" = 1, "6" = 0.1, "8" = 0.5))

## ----lines--------------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg,
          lines = data.frame(slope = -5.344, intercept = 37.285))

## ----lines_style--------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg,
          lines = data.frame(slope = 0,
                             intercept = 30,
                             stroke = "red",
                             stroke_width = 5,
                             stroke_dasharray = "10,5"))

## ----lines_default------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, fixed = TRUE,
          lines = data.frame(slope = c(0, Inf),
                             intercept = c(0, 0),
                             stroke = "#000",
                             stroke_width = 1,
                             stroke_dasharray = 5))

## ----ellipses-----------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, ellipses = TRUE)

## ----ellipses_col-------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl, ellipses = TRUE)

## ----cust_arrows--------------------------------------------------------------
df <- data.frame(x = c(1, 0.9, 0.7, 0.2, -0.4, -0.5),
                 y = c(1, 0.1, -0.5, 0.5, -0.6, 0.7),
                 type_var = c("point", rep("arrow", 5)),
                 lab = LETTERS[1:6])
scatterD3(data = df, x = x, y = y,
          type_var = type_var, lab = lab,
          fixed = TRUE, xlim = c(-1.2, 1.2), ylim = c(-1.2, 1.2))

## ----unit_circle--------------------------------------------------------------
scatterD3(data = df, x = x, y = y,
          type_var = type_var,
          unit_circle = TRUE, fixed = TRUE,
          xlim = c(-1.2, 1.2), ylim = c(-1.2, 1.2))

## ----cust_labels2-------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl, symbol_var = gear,
          xlab = "Weight", ylab = "Mpg", col_lab = "Cylinders", 
          symbol_lab = "Gears")

## ----rm_legend----------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl, col_lab = NA)

## ----cust_labels_legend_size--------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl,
          legend_font_size = "16px")

## ----cust_left_margin---------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl,
          left_margin = 80)

## ----caption_character--------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl,
          caption = "Lorem ipsum dolor sit amet, <strong>consectetur adipiscing
          elit</strong>. Nullam aliquam egestas pretium. Donec auctor semper
          vestibulum. Phasellus in tempor lacus. Maecenas vehicula, ipsum id
          malesuada placerat, diam lorem aliquet lectus, non lacinia quam leo
          quis eros.")

## ----caption_list-------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, col_var = cyl,
          caption = list(title = "Caption title",
                         subtitle = "Caption subtitle",
                         text = "Lorem ipsum dolor sit amet, <strong>consectetur 
                         adipiscing elit</strong>. Nullam aliquam egestas pretium. 
                         Donec auctor semper vestibulum. Phasellus in tempor lacus. 
                         Maecenas vehicula, ipsum id malesuada placerat, diam lorem 
                         aliquet lectus, non lacinia quam leo quis eros."))

## ----urls---------------------------------------------------------------------
mtcars$urls <- paste0("https://www.duckduckgo.com/?q=", rownames(mtcars))
scatterD3(data = mtcars, x = wt, y = mpg, lab = names, url_var = urls)

## ----click_callback-----------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg,
   click_callback = "function(id, d) {
      alert('scatterplot ID: ' + id + ' - Point key_var: ' + d.key_var)
   }")

## ---- click_callback_shiny, eval=FALSE----------------------------------------
#  scatterD3(data = mtcars, x = wt, y = mpg,
#    click_callback = "function(id, d) {
#    if(id && typeof(Shiny) != 'undefined') {
#        Shiny.onInputChange('selected_point', d.key_var);
#    }
#  }")

## ----click_callback_shiny_ui, eval = FALSE------------------------------------
#  textOutput("click_selected")

## ----click_callback_shiny_server, eval = FALSE--------------------------------
#  output$click_selected <- renderText(paste0("Clicked point : ", input$selected_point))

## ----zoom_callback------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg,
   zoom_callback = "function(xmin, xmax, ymin, ymax) {
    var zoom = '<strong>Zoom</strong><br />xmin = ' + xmin + '<br />xmax = ' + xmax + '<br />ymin = ' + ymin + '<br />ymax = ' + ymax;
    document.getElementById('zoomExample').innerHTML = zoom;
   }")

## ----init_callback------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg,
  init_callback = "function() {
    var scales = this.scales();
    var svg = this.svg();
    new_x_axis = scales.xAxis.tickFormat(d3.format(',.0%'));
    svg.select('.x.axis').call(new_x_axis);
  }"
)

## ----nomenu-------------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, menu = FALSE)

## ----lasso--------------------------------------------------------------------
mtcars$names <- rownames(mtcars)
scatterD3(data = mtcars, x = wt, y = mpg, lab = names, lasso = TRUE)

## ----lasso_callback-----------------------------------------------------------
mtcars$names <- rownames(mtcars)
scatterD3(data = mtcars,
          x = wt, y = mpg, lab = names,
          lasso = TRUE,
          lasso_callback = "function(sel) {alert(sel.data().map(function(d) {return d.lab}).join('\\n'));}")

## ----zoom_on------------------------------------------------------------------
scatterD3(data = mtcars, x = wt, y = mpg, zoom_on = c(1.615, 30.4), zoom_on_level = 6, lab = names)

