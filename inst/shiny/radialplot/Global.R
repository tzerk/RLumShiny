## global.R ##
library(Luminescence)
library(RLumShiny)
library(shiny)
library(data.table)

# load example data
data(ExampleData.DeValues)
data <- ExampleData.DeValues$CA1

enableBookmarking(store = "server")