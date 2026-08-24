# Shiny Applications for the R Package Luminescence

A collection of shiny applications for the R package Luminescence. These
mainly, but not exclusively, include applications for plotting
chronometric data from e.g. luminescence or radiocarbon dating. It
further provides access to bootstraps tooltip and popover functionality
as well as a binding to JSColor.

## Details

In addition to its main purpose of providing convenient access to the
Luminescence shiny applications (see
[`app_RLum`](https://tzerk.github.io/RLumShiny/reference/app_RLum.md))
this package also provides further functions to extend the functionality
of shiny. From the Bootstrap framework the JavaScript tooltip and
popover components can be added to any shiny application via
[`tooltip`](https://tzerk.github.io/RLumShiny/reference/tooltip.md) and
[`popover`](https://tzerk.github.io/RLumShiny/reference/popover.md). It
further provides a custom input binding to the JavaScript/HTML color
picker JSColor. Offering access to most options provided by the JSColor
API the function
[`jscolorInput`](https://tzerk.github.io/RLumShiny/reference/jscolorInput.md)
is easily implemented in a shiny app. RGB colors are returned as hex
values and can be directly used in R's base plotting functions without
the need of any format conversion.

## See also

Useful links:

- <https://tzerk.github.io/RLumShiny/>

- Report bugs at <https://github.com/tzerk/RLumShiny/issues>

## Author

**Maintainer**: Christoph Burow <christoph.burow@gmx.net>
([ORCID](https://orcid.org/0000-0002-5023-4046))

Authors:

- Christoph Burow <christoph.burow@gmx.net>
  ([ORCID](https://orcid.org/0000-0002-5023-4046))

- Urs Tilmann Wolpert

- Sebastian Kreutzer ([ORCID](https://orcid.org/0000-0002-0734-2199))

- Marco Colombo ([ORCID](https://orcid.org/0000-0001-6672-0623))

Other contributors:

- R Luminescence Package Team \[contributor\]

- Jan Odvarko (jscolor.js in www/jscolor) \[copyright holder\]

- AnalytixWare (ShinySky package) \[copyright holder\]

- RStudio (chooser_inputBinding.js in www/ and chooser.R in R/)
  \[copyright holder\]
