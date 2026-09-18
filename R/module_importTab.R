importTab <- function(id, label, accept, callback = function() NULL) {

  ## create a namespace function using the provided id
  ns <- NS(id)

  tabPanel("Import",

           h5("Data import"),

           # file upload button
           fileInput(inputId = "file",
                     label = strong(label),
                     accept = accept),

           ## callback function
           callback()
           )
}
