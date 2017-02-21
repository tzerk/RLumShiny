## Server.R
library(Luminescence)
library(shiny)
library(RLumShiny)
library(data.table)

# load example data
data(ExampleData.DeValues)
data <- list(ExampleData.DeValues$CA1, ExampleData.DeValues$CA1)

enableBookmarking(store = "server")