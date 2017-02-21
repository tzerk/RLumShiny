## global.R ##
library(Luminescence)
library(RLumShiny)
library(shiny)
library(data.table)

# load example data
data(ExampleData.DeValues)

enableBookmarking(store = "server")