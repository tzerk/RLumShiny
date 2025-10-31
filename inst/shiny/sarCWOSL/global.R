## global.R ##
library(Luminescence)
library(RLumShiny)
library(data.table)
library(rhandsontable)

data(ExampleData.BINfileData, envir = environment())

enableBookmarking(store = "server")
