## global.R ##
library(Luminescence)
library(RLumShiny)
library(shiny)

# load example data
data(ExampleData.DeValues, envir = environment())
data <- ExampleData.DeValues$CA1

enableBookmarking(store = "server")