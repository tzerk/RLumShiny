# Create a JSColor picker input widget

Creates a JSColor (Javascript/HTML Color Picker) widget to be used in
shiny applications.

## Usage

``` r
jscolorInput(
  inputId,
  label,
  value,
  position = "bottom",
  color = "transparent",
  mode = "HSV",
  slider = TRUE,
  close = FALSE
)
```

## Arguments

- inputId:

  [character](https://rdrr.io/r/base/character.html) (**required**):
  Specifies the input slot that will be used to access the value.

- label:

  [character](https://rdrr.io/r/base/character.html) (*optional*):
  Display label for the control, or NULL for no label.

- value:

  [character](https://rdrr.io/r/base/character.html) (*optional*):
  Initial RGB value of the color picker. Default is black ('#000000').

- position:

  [character](https://rdrr.io/r/base/character.html) (*with default*):
  Position of the picker relative to the text input ('bottom', 'left',
  'top', 'right').

- color:

  [character](https://rdrr.io/r/base/character.html) (*with default*):
  Picker color scheme ('transparent' by default). Use RGB color coding
  ('000000').

- mode:

  [character](https://rdrr.io/r/base/character.html) (*with default*):
  Mode of hue, saturation and value. Can either be 'HSV' or 'HVS'.

- slider:

  [logical](https://rdrr.io/r/base/logical.html) (*with default*): Show
  or hide the slider.

- close:

  [logical](https://rdrr.io/r/base/logical.html) (*with default*): Show
  or hide a close button.

## See also

Other input.elements:
[shiny::animationOptions](https://rdrr.io/pkg/shiny/man/sliderInput.html),
[shiny::sliderInput](https://rdrr.io/pkg/shiny/man/sliderInput.html);
[shiny::checkboxGroupInput](https://rdrr.io/pkg/shiny/man/checkboxGroupInput.html);
[shiny::checkboxInput](https://rdrr.io/pkg/shiny/man/checkboxInput.html);
[shiny::dateInput](https://rdrr.io/pkg/shiny/man/dateInput.html);
[shiny::dateRangeInput](https://rdrr.io/pkg/shiny/man/dateRangeInput.html);
[shiny::fileInput](https://rdrr.io/pkg/shiny/man/fileInput.html);
[shiny::numericInput](https://rdrr.io/pkg/shiny/man/numericInput.html);
[shiny::passwordInput](https://rdrr.io/pkg/shiny/man/passwordInput.html);
[shiny::radioButtons](https://rdrr.io/pkg/shiny/man/radioButtons.html);
[shiny::selectInput](https://rdrr.io/pkg/shiny/man/selectInput.html),
[shiny::selectizeInput](https://rdrr.io/pkg/shiny/man/selectInput.html);
[shiny::submitButton](https://rdrr.io/pkg/shiny/man/submitButton.html);
[shiny::textInput](https://rdrr.io/pkg/shiny/man/textInput.html)

## Examples

``` r
# html code
jscolorInput("col", "Color", "21BF6B", slider = FALSE)
#> <p>Color</p>
#> <input id="col" value="21BF6B" class="color {hash:true, pickerPosition:&#39;bottom&#39;, pickerBorderColor:&#39;transparent&#39;, pickerFaceColor:&#39;transparent&#39;, pickerMode:&#39;HSV&#39;, slider:false, pickerClosable:false}" onchange="$(&#39;#col&#39;).trigger(&#39;afterChange&#39;)"/>
#> <script>$('#col').trigger('afterChange')</script>

# example app
if (FALSE) { # \dontrun{
shinyApp(
ui = fluidPage(
  jscolorInput(inputId = "col", label = "JSColor Picker",
               value = "21BF6B", position = "right",
               mode = "HVS", close = TRUE),
  plotOutput("plot")
),
server = function(input, output) {
  output$plot <- renderPlot({
    plot(cars, col = input$col, cex = 2, pch = 16)
 })
})
} # }
```
