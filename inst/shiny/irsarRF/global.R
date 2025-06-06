## global.R ##
library(Luminescence)
library(RLumShiny)
library(shiny)
library(data.table)
library(rhandsontable)

data(ExampleData.RLum.Analysis)

enableBookmarking(store = "server")
