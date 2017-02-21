## Server.R
library(Luminescence)
library(shiny)
library(RLumShiny)
library(data.table)

# load example data
data(ExampleData.DeValues)

enableBookmarking(store = "server")