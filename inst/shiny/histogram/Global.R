## global.R ##
library(Luminescence)
library(shiny)
library(RLumShiny)

# load example data
data(ExampleData.DeValues)
data <- ExampleData.DeValues$CA1

enableBookmarking(store = "server")