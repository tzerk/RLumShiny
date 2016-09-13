## global.R ##
library(Luminescence)
library(shiny)
library(RLumShiny)

## read example data set and misapply them for this plot type
data(ExampleData.DeValues, envir = environment())
ExampleData.DeValues <- ExampleData.DeValues$BT998

enableBookmarking(store = "server")