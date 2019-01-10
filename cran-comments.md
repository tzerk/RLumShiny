## Test environments
* local Windows 10 x64 install, R 3.6.0 (2019-01-01 r75943)
* local Windows 10 x64 install, R 3.5.2 (2018-12-20)
* CentOS Linux release 7.6.1810 (Core), R 3.5.1 (2018-07-02)
* Windows Server 2012 R2 x64 (build 9600) (on AppVeyor CI), 3.5.2 Patched (2018-12-31 r75943)
* Ubuntu 14.04.5 LTS (on Travis-CI), 3.5.1 (2018-12-12)
* win-builder (devel and release)

## CRAN Notes
> Namespaces in Imports field not imported from: ‘DT’ ‘knitr’
> All declared Imports should be used.

All imported packages are now used.

## R CMD check results
There were no ERRORs, WARNINGs or NOTEs.

## Downstream dependencies
I have also run R CMD check on downstream dependencies of RLumShiny using
revdepcheck::revdep_check() (https://github.com/tzerk/RLumShiny/tree/master/revdep).

All packages passed.






