## Test environments
* local Windows 10 x64 install, R 3.5.0 (2018-04-23 r74626)
* Windows Server 2012 R2 x64 (build 9600) (on AppVeyor CI), R 3.5.0 Patched (2018-06-13 r74898)
* Ubuntu 14.04.5 LTS (on Travis-CI), R 3.5.0
* win-builder (devel and release)

## CRAN Notes

## R CMD check results
There were no ERRORs, WARNINGs or NOTEs.

## Downstream dependencies
I have also run R CMD check on downstream dependencies of RLumShiny using
devtools::revdep_check() (https://github.com/tzerk/RLumShiny/tree/master/revdep).

All packages passed. There were 0 problems and 2 NOTEs, both unrelated to the dependency on RLumShiny.
