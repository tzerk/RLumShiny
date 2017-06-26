## Test environments
* local Windows 10 x64 install, R-devel (2017-06-24 r72853)
* Ubuntu 12.04 (on Travis-CI), R 3.3.1
* win-builder (devel and release)

## R CMD check results
There were no ERRORs or WARNINGs.

There was 1 NOTE:

* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Christoph Burow <christoph.burow@uni-koeln.de>'

Possibly mis-spelled words in DESCRIPTION:
  chronometric (19:14)
  tooltip (20:43)
  
These are spelled correctly.
  
## Downstream dependencies
I have also run R CMD check on downstream dependencies of RLumShiny using
devtools::revdep_check() (https://github.com/tzerk/RLumShiny/tree/master/revdep).

All packages passed.