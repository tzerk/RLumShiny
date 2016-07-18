## Server.R
library(Luminescence)
library(RLumShiny)
library(shiny)
library(digest)
library(RCurl)

# load example data
data(ExampleData.DeValues, envir = environment())
data <- ExampleData.DeValues$CA1

## MAIN FUNCTION
shinyServer(function(input, output, session) {
  
 
  ### GET DATA SETS
  Data<- reactive({

      ### GET DATA
      if(!is.null(datGet())) {
        if(!is.null(datGet2())) {
          data<- list(datGet(), datGet2())
        } else {
          data<- list(datGet())
        }
      } else {
        data<- list(data)
      }

    
    ### DATA FILTER
    input$exclude
    
    sub<- data
    
    isolate({
      filter.prim<- input$filter.prim
      filter.sec<- input$filter.sec
    })
    
    if(!is.null(filter.prim)) {
      index<- grep(paste(filter.prim, collapse = "|"), data[[1]][,1])
      sub[[1]]<- data[[1]][-index,]
    }
    if(length(data) == 2 && !is.null(filter.sec)) {
      index<- grep(paste(filter.sec, collapse = "|"), data[[2]][,1])
      sub[[2]]<- data[[2]][-index,]
    }
    
    stillSelected.prim<- filter.prim
    stillSelected.sec<- filter.sec
    
    updateSelectInput(session, inputId = "filter.prim", choices = sort(data[[1]][,1]), selected = stillSelected.prim)
    if(length(data) == 2) {
      updateSelectInput(session, inputId = "filter.sec", choices = sort(data[[2]][,1]), selected = stillSelected.sec)
    }
    data<- sub
    
    return(data)
  })
  
  # check and read in file (DATA SET 1)
  datGet<- reactive({
    inFile<- input$file1
    if(is.null(inFile)) return(NULL) # if no file was uploaded return NULL
    return(read.table(file = inFile$datapath, # inFile[1] contains filepath 
                      sep = input$sep, 
                      quote = "", 
                      header = input$headers)) # else return file
  })
  
  # check and read in file (DATA SET 2)
  datGet2<- reactive({
    inFile2<- input$file2
    if(is.null(inFile2)) return(NULL) # if no file was uploaded return NULL
    return(read.table(file = inFile2$datapath, # inFile[1] contains filepath 
                      sep = input$sep, 
                      quote = "", 
                      header = input$headers)) # else return file
  })
  
  # dynamically inject sliderInput for x-axis range
  output$xlim<- renderUI({
    data<- Data()
    if(input$logz == TRUE) {
      sd<- unlist(lapply(data, function(x) x[,2]/x[,1]))
    } else {
      sd<- unlist(lapply(data, function(x) x[,2]))
    }
    prec<- 1/sd
    sliderInput(inputId = "xlim", sep="",
                label = "Range x-axis",
                min = 0, 
                max = round(max(prec)*2, 3),
                value = c(0, max(prec)*1.05))
  })## EndOf::renderUI()
  
  # dynamically inject sliderInput for z-axis range
  output$zlim<- renderUI({
    data<- unlist(lapply(Data(), function(x) x[,1]))
    min<- min(data)
    max<- max(data)
    sliderInput(inputId = "zlim",  sep="",
                label = "Range z-axis", 
                min = min*0.25,
                max = round(max*1.75, 3),
                value = c(min*0.8, max*1.2))
  })## EndOf::renderUI()
  
  
  output$ylim<- renderUI({
    ylim<- plot_AbanicoPlot(Data(), output = TRUE)$ylim
    sliderInput(inputId = "ylim",  sep="",
                label = "Range y-axis",
                min = ylim[1]*4, 
                max = round(ylim[2]*4, 3),
                value = c(ylim[1], ylim[2]))
  })
  
  
  # dynamically inject sliderInput for KDE bandwidth
  output$bw<- renderUI({
    data<- unlist(lapply(Data(), function(x) x[,1]))
    if(input$logz == TRUE) {
      data<- log(data)
      min<- 0.001
      value<- bw.nrd0(data)*2
      max<- value*2
    } else {
      value<- bw.nrd0(data)
      min<- value/4
      max<- value*4
    }
    sliderInput(inputId = "bw",  sep="",
                label = "KDE bandwidth", 
                min = round(min, 3), 
                max = round(max, 3),
                value = value)
  })## EndOf::renderUI()
  
  # observe({
  #   # case: 1 data set, 2 sigma bars --> switch to custom value
  #   if(input$addBar == TRUE && is.null(datGet2())) {
  #     updateSelectInput(session = session, inputId = "centrality", 
  #                       label = "Centrality",
  #                       selected = "custom")
  #   }
  #   # case: 1 data set, 1 sigma bars --> return to mean centrality
  #   if(input$addBar == FALSE && is.null(datGet2())) {
  #     updateSelectInput(session = session, inputId = "centrality", 
  #                       label = "Centrality",
  #                       selected = "mean")
  #   }
  # })  
  
  
  output$centralityNumeric<- renderUI({
    #update_centrality()
    if(!is.null(datGet())){
      data<- datGet()
    }
    numericInput(inputId = "centralityNumeric", 
                 label = "Value", 
                 value = round(mean(data[,1]), 2),
                 step = 0.01)
  })
  
  # render Abanico Plot
  output$main_plot <- renderPlot({
    
    # refresh plot on button press
    input$refresh
    
    # progress bar
    progress<- Progress$new(session, min = 0, max = 5)
    progress$set(message = "Calculation in progress",
                 detail = "Retrieve data")
    on.exit(progress$close())
    
    # make sure that input panels are registered on non-active tabs.
    # by default tabs are suspended and input variables are hence
    # not available
    outputOptions(x = output, name = "bw", suspendWhenHidden = FALSE)
    outputOptions(x = output, name = "zlim", suspendWhenHidden = FALSE)
    outputOptions(x = output, name = "xlim", suspendWhenHidden = FALSE)
    outputOptions(x = output, name = "ylim", suspendWhenHidden = FALSE)
    outputOptions(x = output, name = "centralityNumeric", suspendWhenHidden = FALSE)
    
    # get data
    data<- Data()
    
    # update progress bar
    progress$set(value = 1)
    progress$set(message = "Calculation in progress",
                 detail = "Get values")
    
    # check if any summary stats are activated, else NA
    ifelse(input$summary, summary<- input$stats, summary<- NA)
    
    # if custom datapoint color get RGB code from separate input panel
    if(input$color == "custom") {
      color<- ifelse(input$jscol1 == "", "black", input$jscol1)
    } else {
      color<- input$color
    }
    
    if(!is.null(datGet2())) {
      # if custom datapoint color get RGB code from separate input panel
      if(input$color2 == "custom") {
        if(input$jscol2 == "") {
          color<- "black"
        } else {
          color2<- input$jscol2
        }
      } else {
        color2<- input$color2
      }
    } else {
      color2<- adjustcolor("white", alpha.f = 0)
    }
    
    # if custom datapoint style get char from separate input panel
    pch<- ifelse(input$pch == "custom", input$custompch, as.integer(input$pch)-1)
    
    # if custom datapoint style get char from separate input panel
    pch2<- ifelse(input$pch2 == "custom", input$custompch2, as.integer(input$pch2)-1)
    
    # update progress bar
    progress$set(value = 2)
    progress$set(message = "Calculation in progress",
                 detail = "Combine values")
    
    # create numeric vector of lines
    line<-  as.numeric(c(input$line1, input$line2,
                         input$line3, input$line4,
                         input$line5, input$line6,
                         input$line7, input$line8))
    
    # create char vector of line colors
    line.col<-  c(input$colline1, input$colline2,
                  input$colline3, input$colline4,
                  input$colline5, input$colline6,
                  input$colline7, input$colline8)
    
    line.col[which(line.col=="#")] <- "#FFFFFF"
    
    # create char vector of line labels
    line.label<- c(input$labline1, input$labline2,
                   input$labline3, input$labline4,
                   input$labline5, input$labline6,
                   input$labline7, input$labline8)
    
    
    # update progress bar
    progress$set(value = 3)
    progress$set(message = "Calculation in progress",
                 detail = "Get values")
    
    # if custom polygon color get RGB from separate input panel or "none"
    if(input$polygon == "custom") {
      polygon.col<- adjustcolor(col = input$rgbPolygon, alpha.f = input$alpha.polygon/100)
    } else {
      polygon.col<- ifelse(input$polygon == "none", 
                           input$polygon, 
                           adjustcolor(col = input$polygon, alpha.f = input$alpha.polygon/100))
    }
    
    # if custom polygon color get RGB from separate input panel or "none"
    # (secondary data set)
    if(input$polygon2 == "custom") {
      polygon.col2<- adjustcolor(col = input$rgbPolygon2, alpha.f = input$alpha.polygon/100)
    } else {
      polygon.col2<- ifelse(input$polygon2 == "none", 
                            input$polygon2, 
                            adjustcolor(col = input$polygon2, alpha.f = input$alpha.polygon/100))
    }
    
    
    # if custom bar color get RGB from separate input panel or "none"
    if(input$bar == "custom") {
      bar.col<- adjustcolor(col = input$rgbBar, alpha.f = input$alpha.bar/100)
    } else {
      bar.col<- ifelse(input$bar == "none", 
                       input$bar, 
                       adjustcolor(col = input$bar, alpha.f = input$alpha.bar/100))
    }
    
    # if custom bar color get RGB from separate input panel or "none"
    # SECONDARY DATA SET
    if(input$bar2 == "custom") {
      bar.col2<- adjustcolor(col = input$rgbBar2, alpha.f = input$alpha.bar/100)
    } else {
      bar.col2<- ifelse(input$bar2 == "none", 
                        input$bar, 
                        adjustcolor(col = input$bar2, alpha.f = input$alpha.bar/100))
    }
    
    # if custom grid color get RGB from separate input panel or "none"
    if(input$grid == "custom") {
      grid.col<- adjustcolor(col = input$rgbGrid, alpha.f = input$alpha.grid/100)
    } else {
      grid.col<- ifelse(input$grid == "none",
                        input$grid, 
                        adjustcolor(col = input$grid, alpha.f = input$alpha.grid/100))
    }
    
    # update progress bar
    progress$set(value = 4)
    progress$set(message = "Calculation in progress",
                 detail = "Almost there...")
    
    # workaround: if no legend wanted set label to NA and hide 
    # symbol on coordinates -999, -999
    if(input$showlegend == FALSE) {
      legend<- c(NA,NA)
      legend.pos<- c(-999,-999)
    } else {
      if(!is.null(datGet2()))
      {
        legend<- c(input$legendname, input$legendname2)
        legend.pos<- input$legend.pos
      } else {
        legend<- c(input$legendname, "")
        legend.pos<- input$legend.pos
      }
    }
    
    # TODO: arg 'bar' handling (custom values, 1 or 2 bars)
    if (input$customSigBar) {
      if (!input$addBar)
        bar <- input$sigmabar1
      if (input$addBar)
        bar <- c(input$sigmabar1, input$sigmabar2)
    } else {
      bar <- TRUE
    }

    
    # check wether a keyword or a numeric value is used for
    # centrality
    if(input$centrality == "custom") {
        centrality<- input$centralityNumeric
    } else {
      centrality<- input$centrality
    }
    
    # check wether predefined or custom dispersion
    dispersion<- ifelse(input$dispersion == "custom", paste("p", input$cinn, sep=""), input$dispersion)
    
    # validate(need()) makes sure that all data are available to
    # renderUI({}) before plotting and will wait until there
    validate(need(expr = input$bw, message = ''),
             need(expr = input$zlim, message = ''),
             need(expr = input$ylim, message = ''),
             need(expr = input$centralityNumeric, message = 'Waiting for data... Please wait!'))
    
    # save all arguments in a list
    args<- list(data = data,
                summary.pos = input$sumpos,
                y.axis = input$yaxis,
                bw = input$bw,
                bar = bar,
                dispersion = dispersion,
                plot.ratio = input$p.ratio,
                z.0 = centrality, 
                log.z = input$logz, 
                summary = summary,
                col = c(color,color2),
                pch = c(pch,pch2),
                zlab = input$zlab,
                main = input$main,
                zlim = input$zlim, 
                cex = input$cex,
                mtext = input$mtext,
                stats = input$statlabels,
                error.bars = input$errorbars,
                line = line,
                line.col = line.col,
                line.label = line.label,
                polygon.col = c(polygon.col,polygon.col2),
                bar.col = c(bar.col, bar.col2),
                grid.col = grid.col,
                legend = legend,
                legend.pos = legend.pos,
                na.rm = input$naExclude,
                lwd = c(input$lwd, input$lwd2),
                xlab = c(input$xlab1, input$xlab2),
                ylab = input$ylab,
                lty = c(as.integer(input$lty), as.integer(input$lty2)),
                xlim = input$xlim,
                ylim = input$ylim,
                rug = input$rug,
                layout = input$layout,
                rotate = input$rotate,
                kde = input$kde,
                hist = input$histogram,
                dots = input$dots,
                frame = input$frame)
    
    progress$set(value = 5)
    progress$set(message = "Calculation in progress",
                 detail = "Ready to plot")
    
    # plot Abanico Plot 
    do.call(what = plot_AbanicoPlot, args = args)
    
    # char vector for code output
    verb.line<- paste("c(", 
                      line[1], ",",
                      line[2], ",",
                      line[3], ",",
                      line[4], ",",
                      line[5], ",",
                      line[6], ",",
                      line[7], ",",
                      line[8], 
                      ")", sep = "")
    
    # char vector for code output
    verb.line.col<- paste("c('", 
                          line.col[1], "','",
                          line.col[2], "','",
                          line.col[3], "','",
                          line.col[4], "','",
                          line.col[5], "','",
                          line.col[6], "','",
                          line.col[7], "','",
                          line.col[8], 
                          "')", sep = "")
    
    # char vector for code output
    verb.line.label<- paste("c('", 
                            line.label[1], "','",
                            line.label[2], "','",
                            line.label[3], "','",
                            line.label[4], "','",
                            line.label[5], "','",
                            line.label[6], "','",
                            line.label[7], "','",
                            line.label[8], 
                            "')", sep = "")
    
    # char vector for code output
    if(length(legend.pos) == 2) {
      verb.legend.pos<- "c(-999,-999)"
    } else {
      verb.legend.pos<- paste("'", legend.pos, "'", sep="")
    }
    
    # char vector for code output
    verb.summary<- "c('"
    for(i in 1:length(summary)){
      verb.summary<- paste(verb.summary, summary[i], "','", sep="")
      if(i == length(summary)) {
        verb.summary<- substr(verb.summary, 1, nchar(verb.summary)-2)
        verb.summary<- paste(verb.summary, ")", sep="")
      }
    }
    
    # char vector for code output
    if(!is.null(input$statlabels)) {
      verb.stats<- "c('"
      for(i in 1:length(input$statlabels)){
        verb.stats<- paste(verb.stats, input$statlabels[i], "','", sep="")
        if(i == length(input$statlabels)) {
          verb.stats<- substr(verb.stats, 1, nchar(verb.stats)-2)
          verb.stats<- paste(verb.stats, ")", sep="")
        }
      }
    } else {
      verb.stats<- "''"
    }
    
    # char vector for code output
    if (length(bar) == 1)
      verb.bar <- bar
    else
      verb.bar <- paste0("c(", input$sigmabar1, ", ", input$sigmabar2, ")")
    
    # char vector for code output
    if(is.numeric(centrality) == TRUE) {
      verb.centrality<- input$centralityNumeric
    } else {
      verb.centrality<- paste("'",centrality,"'", sep = "")
    }
    
    # char vectors for code output
    str1 <- paste0("plot_AbanicoPlot(data = data, ")
    str2 <- paste0("summary.pos = '", input$sumpos,"',")
    str3 <- paste0("y.axis = ",input$yaxis, ",")
    str4 <- paste0("z.0 = ",verb.centrality,",")
    str5 <- paste0("bw = ",input$bw,",")
    str6 <- paste0("dispersion = '",dispersion,"',")
    str7 <- paste0("plot.ratio = ",input$p.ratio,",")
    str8 <- paste0("bar = ", verb.bar, ",")
    str9 <- paste0("log.z = ",input$logz, ",")
    str10 <- paste0("summary = ",verb.summary,",")
    str11 <- paste0("col = c('",color,"','",color2,"'),")
    str12 <- paste0("pch = c(",pch,",",pch2,"),")
    str13 <- paste0("zlab = '",input$zlab,"',")
    str14 <- paste0("main = '",input$main,"',")
    str15 <- paste0("zlim = c(",input$zlim[1],",",input$zlim[2],"),")
    str16 <- paste0("cex = ", input$cex, ",")
    str17 <- paste0("mtext = '",input$mtext,"',")
    str18 <- paste0("stats = ",verb.stats,",")
    str19 <- paste0("error.bars = ",input$errorbars,",")
    str20 <- paste0("line = ",verb.line,",")
    str21 <- paste0("line.col = ",verb.line.col,",")
    str22 <- paste0("line.label = ",verb.line.label,",")
    str23 <- paste0("polygon.col = c('",polygon.col,"','",polygon.col2,"'),")
    str24 <- paste0("bar.col = c('",bar.col,"','",bar.col2,"'),")
    str25 <- paste0("grid.col = '",grid.col,"',")
    str26 <- paste0("legend = c('",legend[1],"','",legend[2],"'),")
    str27 <- paste0("legend.pos = ",verb.legend.pos,",")
    str28 <- paste0("na.rm = ",input$naExclude,",")
    str29 <- paste0("lwd = c(",input$lwd,",",input$lwd2,"),")
    str30 <- paste0("xlab = c('", input$xlab1,"','",input$xlab2,"'),")
    str31 <- paste0("ylab = '",input$ylab,"',",sep ="")
    str32 <- paste0("lty = c(",as.integer(input$lty),",",as.integer(input$lty2),"),")
    str33 <- paste0("xlim = c(", input$xlim[1],",",input$xlim[2],"),")
    str34 <- paste0("ylim = c(", input$ylim[1],",",input$ylim[2],"),")
    str35 <- paste0("rug = ", input$rug, ",")
    str36 <- paste0("layout = '", input$layout, "',")
    str37 <- paste0("rotate = ", input$rotate, ",")
    str38 <- paste0("kde = ", input$kde, ",")
    str39 <- paste0("hist = ", input$histogram, ",")
    str40 <- paste0("dots = ", input$dots, ",")
    str41 <- paste0("frame = ", input$frame, ")")
    
    
    if(is.null(input$sep)) updateRadioButtons(session, "fileformat", selected = "\t")
    
    if(input$sep == "\t") { verb.sep<-  "\\t"}
    else {
      verb.sep<- input$sep
    }
    
    str0.1 <- paste("data <- read.delim(file, header = ",input$headers, ", sep= '", verb.sep,"')",
                    sep = "")
    if(!is.null(datGet2())) {
      str0.2.0 <- "file2<- file.choose()"
      str0.2.1 <- paste("data2 <- read.delim(file2, header = ",input$headers, ", sep= '", verb.sep,"')",
                        sep= "")
      str0.2.2 <- "data<- list(data, data2)"
      str0.1 <- paste(str0.1, str0.2.0, str0.2.1, str0.2.2, sep = "\n")
    }
    
    str0 <- paste("# To reproduce the plot in your local R environment",
                  "# copy and run the following code to your R console.",
                  "library(Luminescence)",
                  "file<- file.choose()",
                  str0.1,
                  "\n",
                  str1,
                  sep = "\n")
    
    code.output<- paste(str0,
                        str2, str3, str4, str5, str6, str7, str8, str9, str10, 
                        str11, str12, str13, str14, str15, str16, str17, str18, str19, str20, 
                        str21, str22, str23, str24, str25, str26, str27, str28, str29, str30,
                        str31, str32, str33, str34, str35, str36, str37, str38, str39, str40,
                        str41,
                        sep="\n   ")
    
    # nested renderText({}) for code output on "R plot code" tab
    output$plotCode<- renderText({
      
      code.output
      
    })##EndOf::renderText({})
    
    
    output$exportScript <- downloadHandler(
      filename = function() { paste(input$filename, ".", "R", sep="") },
      content = function(file) {
        write(code.output, file)
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
        
        # plot Abanico Plot 
        do.call(what = plot_AbanicoPlot, args = args)
        
        dev.off()
      },#EO content =,
      contentType = "image"
    )#EndOf::dowmloadHandler()
  })##EndOf::renderPlot({})
  
  
  Selected<- reactive({
    input$refresh
  })
  
  # renderTable() that prints the data to the second tab
  output$dataset<- renderDataTable(
    options = list(pageLength = 10, autoWidth = FALSE),
    callback = "function(table) {
      table.on('click.dt', 'tr', function() {
        $(this).toggleClass('selected');
        Shiny.onInputChange('rows',
                            table.rows('.selected').data().toArray());
      });
    }",
{
  if(!is.null(datGet())) {
    data<- datGet()
    colnames(data)<- c("De","De error")
    data
    
  } else {
    colnames(data)<- c("De","De error")
    Selected()
    data
  }
})##EndOf::renterTable()
  
  # renderTable() that prints the secondary data to the second tab
  output$dataset2<- renderDataTable(
    options = list(pageLength = 10, autoWidth = FALSE),
    callback = "function(table) {
      table.on('click.dt', 'tr', function() {
        $(this).toggleClass('selected');
        Shiny.onInputChange('rows',
                            table.rows('.selected').data().toArray());
      });
    }",
{
  if(!is.null(datGet2())) {
    data<- datGet2()
    colnames(data)<- c("De","De error")
    data
  } else {
  }
})##EndOf::renterTable()
  
  # renderTable() to print the results of the
  # central age model (CAM)
  output$CAM<- renderDataTable(
    options = list(pageLength = 10, autoWidth = FALSE),
    {
      data<- Data()
      t<- as.data.frame(matrix(nrow = length(data), ncol = 7))
      colnames(t)<- c("Data set","n", "log data", "Central dose", "SE abs.", "OD (%)", "OD error (%)")
      res<- lapply(data, function(x) { calc_CentralDose(x, verbose = FALSE, plot = FALSE) })
      for(i in 1:length(res)) {
        t[i,1]<- ifelse(i==1,"pimary","secondary")
        t[i,2]<- length(res[[i]]@data$data[,1])
        t[i,3]<- res[[i]]@data$args$log
        t[i,4:7]<- round(res[[i]]@data$summary[1:4],2)
      }
      t
    })##EndOf::renterTable()
  
})##EndOf::shinyServer(function(input, output)