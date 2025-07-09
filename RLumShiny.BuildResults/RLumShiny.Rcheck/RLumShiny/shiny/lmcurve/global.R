## global.R ##
library(Luminescence)
library(RLumShiny)
library(data.table)
library(rhandsontable)

data("ExampleData.FittingLM", envir = environment())

enableBookmarking(store = "server")
