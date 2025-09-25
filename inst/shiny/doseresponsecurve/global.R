## global.R ##
library(Luminescence)
library(RLumShiny)
library(data.table)
library(rhandsontable)

data(ExampleData.LxTxData, envir = environment())

enableBookmarking(store = "server")
