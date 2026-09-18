# Create a bootstrap button with popover

Add small overlays of content for housing secondary information.

## Usage

``` r
popover(
  title,
  content,
  header = NULL,
  html = TRUE,
  class = "btn btn-default",
  placement = c("right", "top", "left", "bottom"),
  trigger = c("click", "hover", "focus", "manual")
)
```

## Arguments

- title:

  [`character`](https://rdrr.io/r/base/character.html) (**required**):
  Title of the button.

- content:

  [`character`](https://rdrr.io/r/base/character.html) (**required**):
  Text to be displayed in the popover.

- header:

  [`character`](https://rdrr.io/r/base/character.html) (*optional*):
  Optional header in the popover.

- html:

  [`logical`](https://rdrr.io/r/base/logical.html) (*with default*):
  Insert HTML into the popover.

- class:

  [`logical`](https://rdrr.io/r/base/logical.html) (*with default*):
  Bootstrap button class (e.g. "btn btn-danger").

- placement:

  [`character`](https://rdrr.io/r/base/character.html) (*with default*):
  How to position the popover - top \| bottom \| left \| right \| auto.
  When "auto" is specified, it will dynamically reorient the popover.
  For example, if placement is "auto left", the popover will display to
  the left when possible, otherwise it will display right.

- trigger:

  [`character`](https://rdrr.io/r/base/character.html) (*with default*):
  How popover is triggered - click \| hover \| focus \| manual.

## Examples

``` r
# html code
popover("title", "Some content")
#> <a tabindex="0" role="button" class="btn btn-default" data-toggle="popover" data-content="Some content" data-animation="TRUE" html="TRUE" data-placement="right" data-trigger="click">title</a>

# example app
if (FALSE) { # \dontrun{
shinyApp(
ui = fluidPage(
  jscolorInput(inputId = "col", label = "JSColor Picker", 
               value = "21BF6B", position = "right", 
               mode = "HVS", close = TRUE),
  popover(title = "Help!", content = "Call 911"),
  plotOutput("plot")
),
server = function(input, output) {
  output$plot <- renderPlot({
    plot(cars, col = input$col, cex = 2, pch = 16)
 })
})
} # }
```
