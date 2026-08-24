# Create a bootstrap tooltip

Create bootstrap tooltips for any HTML element to be used in shiny
applications.

## Usage

``` r
tooltip(
  refId,
  text,
  attr = NULL,
  animation = TRUE,
  delay = 100,
  html = TRUE,
  placement = "auto",
  trigger = "hover"
)
```

## Arguments

- refId:

  [`character`](https://rdrr.io/r/base/character.html) (**required**):
  id of the element the tooltip is to be attached to.

- text:

  [`character`](https://rdrr.io/r/base/character.html) (**required**):
  Text to be displayed in the tooltip.

- attr:

  [`character`](https://rdrr.io/r/base/character.html) (*optional*):
  Attach tooltip to all elements with attribute `attr='refId'`.

- animation:

  [`logical`](https://rdrr.io/r/base/logical.html) (*with default*):
  Apply a CSS fade transition to the tooltip.

- delay:

  [`numeric`](https://rdrr.io/r/base/numeric.html) (*with default*):
  Delay showing and hiding the tooltip (ms).

- html:

  [`logical`](https://rdrr.io/r/base/logical.html) (*with default*):
  Insert HTML into the tooltip.

- placement:

  [`character`](https://rdrr.io/r/base/character.html) (*with default*):
  How to position the tooltip - `top` \| `bottom` \| `left` \| `right`
  \| `auto`. When 'auto' is specified, it will dynamically reorient the
  tooltip. For example, if placement is 'auto left', the tooltip will
  display to the left when possible, otherwise it will display right.

- trigger:

  [`character`](https://rdrr.io/r/base/character.html) (*with default*):
  How tooltip is triggered - `click` \| `hover` \| `focus` \| `manual`.
  You may pass multiple triggers; separate them with a space.

## Examples

``` r
# javascript code
tt <- tooltip("elementId", "This is a tooltip.")
str(tt)
#> List of 1
#>  $ :List of 3
#>   ..$ name    : chr "head"
#>   ..$ attribs : Named list()
#>   ..$ children:List of 1
#>   .. ..$ :List of 3
#>   .. .. ..$ name    : chr "script"
#>   .. .. ..$ attribs : Named list()
#>   .. .. ..$ children:List of 1
#>   .. .. .. ..$ : 'html' chr "$(window).load(function(){ $('#elementId').tooltip({ html: true, \n                  trigger: 'hover', title: '"| __truncated__
#>   .. .. .. .. ..- attr(*, "html")= logi TRUE
#>   .. .. ..- attr(*, "class")= chr "shiny.tag"
#>   ..- attr(*, "class")= chr "shiny.tag"
#>  - attr(*, "class")= chr [1:2] "shiny.tag.list" "list"

# example app
if (FALSE) { # \dontrun{
shinyApp(
ui = fluidPage(
  jscolorInput(inputId = "col", label = "JSColor Picker", 
               value = "21BF6B", position = "right", 
               mode = "HVS", close = TRUE),
  tooltip("col", "This is a JScolor widget"),
  
  checkboxInput("cbox", "Checkbox", FALSE),
  tooltip("cbox", "This is a checkbox"),
  
  checkboxGroupInput("cboxg", "Checkbox group", selected = "a", 
                     choices = c("a" = "a",
                                 "b" = "b",
                                 "c" = "c")),
  tooltip("cboxg", "This is a <b>checkbox group</b>", html = TRUE),
  
  selectInput("select", "Selectinput", selected = "a", choices = c("a"="a", "b"="b")),
  tooltip("select", "This is a text input field", attr = "for", placement = "right"),
  
  passwordInput("pwIn", "Passwordinput"),
  tooltip("pwIn", "This is a password input field"),
  
  plotOutput("plot")
),
server = function(input, output) {
  output$plot <- renderPlot({
    plot(cars, col = input$col, cex = 2, pch = 16)
 })
})
} # }
```
