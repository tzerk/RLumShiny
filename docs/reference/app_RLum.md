# Run Luminescence shiny apps

A wrapper for [shiny::runApp](https://rdrr.io/pkg/shiny/man/runApp.html)
to start interactive shiny apps for the R package Luminescence.

The RLumShiny package provides a single function from which all shiny
apps can be started: `app_RLum()`. It essentially only takes one
argument, which is a unique keyword specifying which application to
start. See the table below for a list of available shiny apps and which
keywords to use. If no keyword is used a dashboard will be started
instead, from which an application can be started.

|  |  |  |
|----|----|----|
| **Application name:** | **Keyword:** | **Function:** |
| Abanico Plot | *abanico* | [Luminescence::plot_AbanicoPlot](https://r-lum.github.io/Luminescence/reference/plot_AbanicoPlot.html) |
| Histogram | *histogram* | [Luminescence::plot_Histogram](https://r-lum.github.io/Luminescence/reference/plot_Histogram.html) |
| Kernel Density Estimate Plot | *KDE* | [Luminescence::plot_KDE](https://r-lum.github.io/Luminescence/reference/plot_KDE.html) |
| Radial Plot | *radialplot* | [Luminescence::plot_RadialPlot](https://r-lum.github.io/Luminescence/reference/plot_RadialPlot.html) |
| Aliquot Size | *aliquotsize* | [Luminescence::calc_AliquotSize](https://r-lum.github.io/Luminescence/reference/calc_AliquotSize.html) |
| Dose Recovery Test | *doserecovery* | [Luminescence::plot_DRTResults](https://r-lum.github.io/Luminescence/reference/plot_DRTResults.html) |
| Dose ResponseCurve | *doseresponsecurve* | [Luminescence::plot_DoseResponseCurve](https://r-lum.github.io/Luminescence/reference/plot_DoseResponseCurve.html) |
| Cosmic Dose Rate | *cosmicdose* | [Luminescence::calc_CosmicDoseRate](https://r-lum.github.io/Luminescence/reference/calc_CosmicDoseRate.html) |
| CW Curve Transformation | *transformCW* | [Luminescence::convert_CW2pHMi](https://r-lum.github.io/Luminescence/reference/convert_CW2pHMi.html), [Luminescence::convert_CW2pLM](https://r-lum.github.io/Luminescence/reference/convert_CW2pLM.html), [Luminescence::convert_CW2pLMi](https://r-lum.github.io/Luminescence/reference/convert_CW2pLMi.html), [Luminescence::convert_CW2pPMi](https://r-lum.github.io/Luminescence/reference/convert_CW2pPMi.html) |
| Filter Combinations | *filter* | [Luminescence::plot_FilterCombinations](https://r-lum.github.io/Luminescence/reference/plot_FilterCombinations.html) |
| Fast Ratio | *fastratio* | [Luminescence::calc_FastRatio](https://r-lum.github.io/Luminescence/reference/calc_FastRatio.html) |
| Fading Correction | *fading* | [Luminescence::analyse_FadingMeasurement](https://r-lum.github.io/Luminescence/reference/analyse_FadingMeasurement.html), [Luminescence::calc_FadingCorr](https://r-lum.github.io/Luminescence/reference/calc_FadingCorr.html) |
| Finite Mixture | *finitemixture* | [Luminescence::calc_FiniteMixture](https://r-lum.github.io/Luminescence/reference/calc_FiniteMixture.html) |
| Huntley (2006) | *huntley2006* | [Luminescence::calc_Huntley2006](https://r-lum.github.io/Luminescence/reference/calc_Huntley2006.html) |
| IRSAR RF | *irsarRF* | [Luminescence::analyse_IRSAR.RF](https://r-lum.github.io/Luminescence/reference/analyse_IRSAR.RF.html) |
| LM Curve | *lmcurve* | [Luminescence::fit_LMCurve](https://r-lum.github.io/Luminescence/reference/fit_LMCurve.html) |
| Portable OSL | *portableOSL* | [Luminescence::analyse_portableOSL](https://r-lum.github.io/Luminescence/reference/analyse_portableOSL.html) |
| SAR CWOSL | *sarCWOSL* | [Luminescence::analyse_SAR.CWOSL](https://r-lum.github.io/Luminescence/reference/analyse_SAR.CWOSL.html) |
| Test Stimulation Power | *teststimulationpower* | [Luminescence::plot_RLum](https://r-lum.github.io/Luminescence/reference/plot_RLum.html) |
| Scale Gamma Dose Rate | *scalegamma* | [Luminescence::scale_GammaDose](https://r-lum.github.io/Luminescence/reference/scale_GammaDose.html) |
| RCarb app | *RCarb* | [RCarb::model_DoseRate](https://r-lum.github.io/RCarb/reference/model_DoseRate.html) |

The `app_RLum()` function is just a wrapper for
[shiny::runApp](https://rdrr.io/pkg/shiny/man/runApp.html). Via the
`...` argument further arguments can be directly passed to
[shiny::runApp](https://rdrr.io/pkg/shiny/man/runApp.html). See
[`?shiny::runApp`](https://rdrr.io/pkg/shiny/man/runApp.html) for
further details on valid arguments.

## Usage

``` r
app_RLum(app = NULL, ...)
```

## Arguments

- app:

  [character](https://rdrr.io/r/base/character.html) (**required**):
  name of the application to start. See details for a list of available
  apps.

- ...:

  further arguments to pass to
  [shiny::runApp](https://rdrr.io/pkg/shiny/man/runApp.html)

## See also

[shiny::runApp](https://rdrr.io/pkg/shiny/man/runApp.html)

## Author

Christoph Burow, University of Cologne (Germany)

## Examples

``` r

if (FALSE) { # \dontrun{
# Dashboard
app_RLum()

# Plotting apps
app_RLum("abanico")
app_RLum("histogram")
app_RLum("KDE")
app_RLum("radialplot")
app_RLum("doserecovery")
app_RLum("doseresponsecurve")

# Further apps
app_RLum("aliquotsize")
app_RLum("cosmicdose")
app_RLum("transformCW")
app_RLum("filter")
app_RLum("fastratio")
app_RLum("fading")
app_RLum("finitemixture")
app_RLum("huntley2006")
app_RLum("irsarRF")
app_RLum("lmcurve")
app_RLum("portableOSL")
app_RLum("sarCWOSL")
app_RLum("surfaceexposure")
app_RLum("teststimulationpower")
app_RLum("scalegamma")
app_RLum("RCarb")
} # }
```
