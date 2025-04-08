## global.R ##
library(Luminescence)
library(RLumShiny)
library(shiny)
library(data.table)
library(rhandsontable)

data("ExampleData.portableOSL", envir = environment())

enableBookmarking(store = "server")
