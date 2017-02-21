## global.R ##
library(Luminescence)
library(RLumShiny)
library(shiny)
library(data.table)

data("ExampleData.CW_OSL_Curve", envir = environment())

enableBookmarking(store = "server")