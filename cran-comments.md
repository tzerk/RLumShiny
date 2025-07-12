## Test environments

-   local Fedora 42 x64 install, R 4.5.0 (2025-04-11)
-   win-builder (devel, release, oldrel)

## CRAN Notes

## R CMD check results

There were no ERRORs, WARNINGs or NOTEs.

## Win-Builder check results

### devel

There was 1 ERROR.

"Package required and available but unsuitable version: 'shiny'"

The package source for 'shiny' 1.11.1 is already available, just not yet
built for R-devel on windows.

### oldrel

There was 1 NOTE.

"Author field differs from that derived from Authors\@R"

In our DESCRIPTION we only provide the Authors\@R.

## Downstream dependencies

I have also run R CMD check on downstream dependencies of RLumShiny using revdepcheck::revdep_check() (<https://github.com/tzerk/RLumShiny/tree/master/revdep>).

All packages passed.
