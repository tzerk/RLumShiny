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

#' Internal helper function to choose a custom symbol
#'
#' @noRd
customSymbolChooser <- function(inputId, label = "Insert character") {
  textInput(inputId = inputId,
            label = label,
            value = "?")
}
