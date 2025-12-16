## Server.R
## MAIN FUNCTION
function(input, output, session) {
  session$onSessionEnded(function() {
    stopApp()
  })

  # function to convert coordinates to degree decimal format
  coord_conv <- function(x, id) {
    if (id == "degDecMin") {
      x <- c(sum(input$degN_1, input$decMinN/60),
            sum(input$degE_1, input$decMinE/60))
    }

    if (id == "degMinSec") {
      x <- c(sum(input$degN_2,input$minN/60,input$secN/3600),
            sum(input$degE_2,input$minE/60,input$secE/3600))
    }

    return(x)
  }

  # coordinate conversion
  coords <- reactive({
    if(input$coords != "decDeg") {
      LatLong <- if(input$coords == "degDecMin" ) {
        coord_conv(, id = "degDecMin")  # YES
      } else {
        coord_conv(, id = "degMinSec")  # NO
      }

    } else {
      LatLong <- c(input$decDegN, input$decDegE)
    }

    # return data frame
    data.frame(Lat = LatLong[1], Long = LatLong[2])
  })

  # render OpenStreetMap
  output$map <- leaflet::renderLeaflet({
    # refresh plot on button press
    input$refresh

    coords <- coords()
    leaflet::leaflet() |>
      leaflet::addTiles() |>
      leaflet::setView(coords$Long, coords$Lat, zoom = 17) |>
      leaflet::addPopups(coords$Long, coords$Lat, 'Sampling site')
  })


  # get results from calc_CosmicDoseRate() function
  get_results<- reactive({
    # get coordinates
    coords<- coords()
    lat <- coords$Lat
    long <- coords$Long

    # get absorber properties
    depth <- na.omit(c(input$depth_1, input$depth_2, input$depth_3, input$depth_4, input$depth_5))
    density <- na.omit(c(input$density_1, input$density_2, input$density_3, input$density_4, input$density_5))

    ## don't crash on previously set values (issue #23)
    if (input$mode == "sAxS") {
      density <- density[1]
    }

    ## remove existing notifications
    removeNotification(id = "notification")

    res <- tryNotify(calc_CosmicDoseRate(depth = as.numeric(depth),
                                         density = as.numeric(density),
                                         latitude = lat,
                                         longitude = long,
                                         altitude = as.numeric(input$altitude),
                                         corr.fieldChanges = input$corr,
                                         est.age = input$estage,
                                         half.depth = input$half,
                                         verbose = FALSE,
                                         error = input$error))
    if (inherits(res, "RLum.Results"))
      get_RLum(res, "summary")
  })


  # render results for mode 1 and 2
  output$results<- renderUI({
    # refresh plot on button press
    input$refresh

    if(input$mode == "sAsS" || input$mode == "xAsS") {
      t<- get_results()
      if (!inherits(t, "data.frame"))
        return()

      HTML(
        if(input$mode=="xAsS") {
          paste("Sample depth: ","<font size='3'>", "<code>",
                sum(na.omit(input$depth_1), na.omit(input$depth_2), na.omit(input$depth_3), na.omit(input$depth_4), na.omit(input$depth_5)),
                "m", "</code>", "</font>", "<br>")
        },
        "Total absorber: ","<font size='3'>", "<code>", t$total_absorber.gcm2, "g/cm\u00b2", "</code>", "</font>", "<br>",
        "Cosmic dose rate (uncorrected): ","<font size='3'>", "<code>", round(t$d0, 3), "Gy/ka", "</code>", "</font>", "<br>",
        "Geomagnetic latitude: ","<font size='3'>", "<code>", round(t$geom_lat, 2), "\u00b0", "</code>", "</font>", "<br>",
        "Cosmic dose rate (corrected): ","<font size='3'>", "<code>", round(t$dc, 3),"\u00b1", round(t$dc/100*input$error, 3), "Gy/ka", "</code>", "<br> ", "</font>"
      )
    }
  })

  # render results for mode 3
  output$resultsTable<- DT::renderDT({
    # refresh plot on button press
    input$refresh

    if(input$mode == "sAxS") {
      t<- get_results()
      table<- as.data.frame(cbind(t$depth, t$total_absorber.gcm2, round(t$d0, 3), round(t$dc,3), round(t$dc/100*input$error, 3)))
      colnames(table)<- c("Depth (m)",
                          "Absorber (g/cm\u00b2)",
                          "Dc (Gy/ka) [uncorrected]",
                          "Dc (Gy/ka) [corrected]",
                          "Dc error (Gy/ka)")
      table
    }
  }, options=list(autoWidth = FALSE, paging = FALSE, processing = TRUE)) # jQuery DataTables options (https://datatables.net)
}
