## global.R ##
library(Luminescence)
library(shiny)
library(RLumShiny)
library(data.table)

## read example data set and misapply them for this plot type
data(ExampleData.DeValues, envir = environment())

enableBookmarking(store = "server")