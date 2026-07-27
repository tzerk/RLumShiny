#' Internal helper function to choose the symbol for points
#'
#' @noRd
pointSymbolChooser <- function(inputId, selected, label = "Style") {
  selectInput(inputId = inputId,
              label = label,
              selected = selected,
              choices = c("Square"= "0",
                          "Circle"="1",
                          "Triangle point up"="2",
                          "Plus"="3",
                          "Cross"="4",
                          "Diamond"="5",
                          "Triangle point down"="6",
                          "Square cross"="7",
                          "Star"="8",
                          "Diamond plus"="9",
                          "Circle plus"="10",
                          "Triangles up and down"="11",
                          "Square plus"="12",
                          "Circle cross"="13",
                          "Square and Triangle up"="14",
                          "filled Square"="15",
                          "filled Circle"="16",
                          "filled Triangle point up"="17",
                          "filled Diamond"="18",
                          "solid Circle"="19",
                          "Bullet (smaller Circle)"="20",
                          "filled Circle w/outline"="21",
                          "Custom"="custom"))
}

#' Internal helper function to choose the line type
#'
#' @noRd
lineTypeChooser <- function(inputId, selected, label = "Line type") {
  selectInput(inputId = inputId,
              label = label,
              selected = selected,
              choices = list("Blank" = 0,
                             "Solid" = 1,
                             "Dashed" = 2,
                             "Dotted" = 3,
                             "Dot dash" = 4,
                             "Long dash" = 5,
                             "Two dash" = 6))
}

#' Internal helper function to choose the line width
#'
#' @noRd
lineWidthChooser <- function(inputId, label = "Line width") {
  numericInput(inputId = inputId,
               label = label,
               value = 1,
               min = 0, max = 5, step = 0.5)
}

#' Internal helper function to choose the legend position
#'
#' @noRd
legendPositionChooser <- function(inputId, selected, label = "Legend position") {
  selectInput(inputId = inputId,
              label = label,
              selected = selected,
              choices = c("Top" = "top",
                          "Top left" = "topleft",
                          "Top right" = "topright",
                          "Center" = "center",
                          "Bottom" = "bottom",
                          "Bottom left" = "bottomleft",
                          "Bottom right" = "bottomright"))
}

#' Internal helper function to choose the summary position
#'
#' @noRd
summaryPositionChooser <- function(inputId, selected, label = "Summary position") {
  selectInput(inputId = inputId,
              label = label,
              selected = selected,
              choices = list("Subtitle" = "sub",
                             "Center" = "center",
                             Top=c("Top" = "top",
                                   "Top left" = "topleft",
                                   "Top right" = "topright"),
                             Bottom=c("Bottom" = "bottom",
                                      "Bottom left" = "bottomleft",
                                      "Bottom right" = "bottomright")))
  }

#' Internal helper function to choose a custom symbol
#'
#' @noRd
customSymbolChooser <- function(inputId, label = "Insert character") {
  textInput(inputId = inputId,
            label = label,
            value = "?")
}
