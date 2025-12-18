## Test environments

-   local Fedora 42 x64 install, R 4.5.2 (2025-10-31)
-   win-builder (devel, release, oldrel)

## CRAN Notes

## R CMD check results

There were no ERRORs, WARNINGs or NOTEs.

## Win-Builder check results

### devel

Status: OK

### release

Status: OK

### oldrel

Status: 1 NOTE

"Author field differs from that derived from Authors\@R"

In our DESCRIPTION we only provide the Authors\@R.

## Downstream dependencies

I have also run R CMD check on downstream dependencies of RLumShiny using revdepcheck::revdep_check() (<https://github.com/tzerk/RLumShiny/tree/master/revdep>).

All packages passed.
