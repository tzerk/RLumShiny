## global.R ##
library(Luminescence)
library(RLumShiny)
library(shiny)

data("ExampleData.CW_OSL_Curve", envir = environment())
data <- ExampleData.CW_OSL_Curve

enableBookmarking(store = "server")