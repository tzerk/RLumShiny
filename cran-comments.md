## Test environments
* local Windows 10 x64 install, R 3.x.x (xxxx-xx-x rxxxxx)
* Windows Server 2012 R2 x64 (build 9600) (on AppVeyor CI), R 3.5.0 Patched (xxxx-xx-xx rxxxxx)
* Ubuntu 14.04.5 LTS (on Travis-CI), R 3.x.x
* win-builder (devel and release)

## CRAN Notes
> Namespaces in Imports field not imported from: ‘DT’ ‘knitr’
> All declared Imports should be used.

All imported packages are now used.

## R CMD check results
There were no ERRORs, WARNINGs or NOTEs.

## Downstream dependencies
I have also run R CMD check on downstream dependencies of RLumShiny using
devtools::revdep_check() (https://github.com/tzerk/RLumShiny/tree/master/revdep).

All packages passed.
