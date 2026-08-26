## global.R ##
library(Luminescence)
library(RLumShiny)
library(data.table)
library(rhandsontable)
library(plotly)

data(ExampleData.BINfileData, envir = environment())

enableBookmarking(store = "server")


# Helper functions --------------------------------------------------------
.getResultsTable <- function(values, onlyHighlights = FALSE) {
  if (length(values) == 0)
    return(NULL)

  data <- as.data.frame(data.table::rbindlist(values))

  ## remove internal columns
  rm.idx <- grep("^\\.", colnames(data))
  data <- data[, -rm.idx]

  if (onlyHighlights) {
    ## remove columns for secondary model parameters
    rm.idx <- match(c("D01", "D01.ERROR", "D02", "D02.ERROR",
                      "R", "R.LOWER", "R.UPPER",
                      "Dc", "Dc.LOWER", "Dc.UPPER",
                      "D63", "D63.LOWER", "D63.UPPER",
                      "D80", "D80.LOWER", "D80.UPPER",
                      "HPDI68_L", "HPDI68_U", "HPDI95_L", "HPDI95_U",
                      "signal.range", "background.range",
                      "signal.range.Tx", "background.range.Tx", "UID"),
                    colnames(data))
    data <- data[, -rm.idx]
  }

  ## round numerical columns
  num.idx <- vapply(data, is.numeric, logical(1))
  data[num.idx] <- lapply(data[num.idx], round, digits = 3)

  data
}
