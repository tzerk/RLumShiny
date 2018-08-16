## global.R ##
library(Luminescence)
library(RLumShiny)
library(shiny)
library(data.table)
library(rhandsontable)

data("ExampleData.ScaleGammaDose")

example_data <- ExampleData.ScaleGammaDose

f <- function(x, d = 3) formatC(x, digits = d, format = "f")

enableBookmarking(store = "server")