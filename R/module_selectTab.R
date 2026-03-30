selectTab <- function(id, label, callback = function() NULL) {

  ## create a namespace function using the provided id
  ns <- NS(id)

  tabPanel("Select",

           div(align = "center", h5("Curve selection")),

           ## callback function
           callback()
  )
}
