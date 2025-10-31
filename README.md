
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RLumShiny <a href='https://tzerk.github.io/RLumShiny/'><img src='man/figures/logo.png' align="right" height="138.5" /></a>

<!-- badges: start -->

[![CRAN](https://www.r-pkg.org/badges/version/RLumShiny)](https://CRAN.R-project.org/package=RLumShiny)
[![CRAN
DOI](https://img.shields.io/badge/doi-10.32614/CRAN.package.RLumShiny-blue.svg)](https://doi.org/10.32614/CRAN.package.RLumShiny)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/RLumShiny)](https://www.r-pkg.org/pkg/RLumShiny)
[![Downloads](https://cranlogs.r-pkg.org/badges/RLumShiny)](https://www.r-pkg.org/pkg/RLumShiny)
[![Downloads](https://cranlogs.r-pkg.org/badges/last-week/RLumShiny)](https://www.r-pkg.org/pkg/RLumShiny)
[![Downloads](https://cranlogs.r-pkg.org/badges/last-day/RLumShiny)](https://www.r-pkg.org/pkg/RLumShiny)
[![R-CMD-check](https://github.com/R-Lum/RLumShiny/actions/workflows/GitHub_Actions_CI.yaml/badge.svg)](https://github.com/R-Lum/RLumShiny/actions)
<!-- badges: end -->

> Visit the
> <a href="https://tzerk.github.io/RLumShiny/" target="_blank">project
> page</a>!

# Overview

A collection of `shiny` applications for the R package `Luminescence`.
These mainly, but not exclusively, include applications for plotting
chronometric data from e.g. luminescence or radiocarbon dating. It
further provides access to twitter bootstraps tooltip and pop over
functionality and contains the [jscolor.js
library](https://jscolor.com/) with a custom `shiny` output binding.

## Installation

To install the stable version from CRAN, simply run the following from
an R console:

``` r
install.packages("RLumShiny")
```

To install the latest development builds directly from GitHub, run

``` r
if (!require("devtools"))
  install.packages("devtools")
devtools::install_github("tzerk/RLumShiny@master")
```

## Applications

The RLumShiny package provides a single function from which all apps can
be started: `app_RLum()`. It essentially only takes one argument, which
is a unique keyword to specify which app to start. See the table below
for a list of available apps and which keywords to use.

| Application | Keyword | Function |
|----|:--:|----|
| Abanico Plot | abanico | `plot_AbanicoPlot` |
| Histogram | histogram | `plot_Histogram` |
| Kernel Density Estimate Plot | KDE | `plot_KDE` |
| Radial Plot | radialplot | `plot_RadialPlot` |
| Dose Recovery Test | doserecovery | `plot_DRTResults` |
| Dose Response Curve | doseresponsecurve | `plot_DoseResponseCurve` |
| Cosmic Dose Rate | cosmicdose | `calc_CosmicDoseRate` |
| Calculate Aliquot Size | aliquotsize | `calc_AliquotSize` |
| CW Curve Transformation | transformCW | `convert_CW2pHMi`, `convert_CW2pLM`, `convert_CW2pLMi`, `convert_CW2pPMi` |
| Plot Filter Combinations | filter | `plot_FilterCombinations` |
| Calculate Fast Ratio | fastratio | `calc_FastRatio` |
| Fading measurement analysis and correction | fading | `analyse_FadingMeasurement`, `calc_FadingCorr` |
| Fading correction after Huntley 2006 | huntley2006 | `calc_Huntley2006` |
| Analyse IRSAR RF measurements | irsarRF | `analyse_IRSAR.RF` |
| Analyse Portable OSL | portableOSL | `analyse_portableOSL` |
| Analyse SAR CWOSL data | sarCWOSL | `analyse_SAR.CWOSL` |
| Calculate Finite Mixture Model | finitemixture | `calc_FiniteMixture` |
| Fit LM Curve | lmcurve | `fit_LMCurve` |
| Test OSL/IRSL Stimulation Power | teststimulationpower | `plot_RLum` |
| Scale Gamma Dose Rate† | scalegamma | `scale_GammaDose()` |
| Model dose rate evolution in carbonate-rich samples | RCarb | `RCarb::model_DoseRate` |

The `app_RLum()` function is just a wrapper for `shiny::runApp()`. Via
the `...` argument further arguments can be directly passed to
`shiny::runApp()`. See `?shiny::runApp` for further details on valid
arguments.

<!--- * Not yet available in the official CRAN release.  -->

† Requires the development version of the `Luminescence` package (\>
v1.0.1) not yet on CRAN.

## Extending Shiny

In addition to its main purpose of providing convenient access to the
Luminescence shiny applications this package also provides further
functions to extend the functionality of `shiny`. From the Bootstrap
framework the JavaScript tooltip and popover components can be added to
any shiny application via `tooltip()` and `popover()`.

It further provides a custom input binding to the JavaScript/HTML color
picker [JSColor](https://jscolor.com). Offering access to most options
provided by the JSColor API the function `jscolorInput()` is easily
implemented in a shiny app. RGB colors are returned as hex values and
can be directly used in **R**’s base plotting functions without
requiring any format conversion.

## Examples

### Abanico Plot app

`app_RLum("abanico")`

<figure>
<img src="man/figures/abanico.png" alt="Abanico app" />
<figcaption aria-hidden="true">Abanico app</figcaption>
</figure>

### Tooltip

`tooltip(refId, text, attr = NULL, animation = TRUE, delay = 100, html = TRUE, placement = "auto", trigger = "hover")`

<figure>
<img src="man/figures/tooltip.png" alt="tooltip" />
<figcaption aria-hidden="true">tooltip</figcaption>
</figure>

### JSColor

`jscolorInput(inputId, label, value, position = "bottom", color = "transparent", mode = "HSV", slider = TRUE, close = FALSE)`

<figure>
<img src="man/figures/jscolor.png" alt="jscolor.js" />
<figcaption aria-hidden="true">jscolor.js</figcaption>
</figure>

## Contribute

This package is part of the R
[Luminescence](https://r-lum.github.io/Luminescence/) project. The is
based on and evolves from ideas, contributions and constructive
criticism of its users. Help us to maintain and develop the package, to
find bugs and create new functions as well as a user-friendly design.
Visit [r-luminescence website](https://r-luminescence.org) or leave a
message under <https://github.com/tzerk/RLumShiny/issues> if anything
crosses your mind or if you want your new self-written shiny application
to be to implemented. You are kindly invited to bring forward the
package with us!

## Note

This version is a development version and it comes without any
guarantee! For stable branches please visit the package on [CRAN
‘RLumShiny’](https://CRAN.R-project.org/package=RLumShiny).

## License

The `'RLumShiny'` package is licensed under the GPL-3. See these files
in the main directory for additional details:

- [LICENSE.note](https://github.com/tzerk/RLumShiny/blob/master/LICENSE.note)

## Funding

- contributions from 2025 are supported through the DFG programme
  “REPLAY: REProducible Luminescence Data AnalYses” [No
  528704761](https://gepris.dfg.de/gepris/projekt/528704761?language=en)
  led by Dr Sebastian Kreutzer (PI at Heidelberg University, DE) and Dr
  Thomas Kolb (PI at Justus-Liebig-University Giessen, DE).

## Related projects

- [RLumModel](https://github.com/R-Lum/RLumModel)
- [Luminescence](https://github.com/R-Lum/Luminescence)
- [RCarb](https://github.com/R-Lum/RCarb)
