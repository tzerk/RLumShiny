## global.R ##
library(Luminescence)
library(RLumShiny)
library(shiny)
library(data.table)
library(rhandsontable)

data(ExampleData.RF70Curves)

enableBookmarking(store = "server")
