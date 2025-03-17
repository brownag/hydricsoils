# Changes in version 0.1.2

## Improvements

 - Update `fihs` dataset for Field Indicators of Hydric Soils v9.0
 
   - Adds new "All Soils" indicator: "A18" _Iron Monosulfide_

 - Updated `lrrmlra` geometry source URL

## Additions
 
 - Added `lrrmlra_geometry_dsn()` and `hydricsoils_data_dir()` functions for getting data sources and paths
 
# Changes in version 0.1.1

## Improvements

  * Improvements to the initial parsing routine of `fhis` dataset; cross-checked with appendix and text content of the guide.

## Additions

  * Added usage columns `"test_symbols"` and `"test_except_mlra"` to `fihs` dataset indicating where established indicators are being tested

  * Added `plot_indicator_usage()` a terra-based graphical method for visualizing the area of applicability of indicators

  * Added `lrrmlra` dataset containing tabular data describing MLRA and LRR symbols and names

  * Added `lrrmlra_geometry()` and associated cache-management methods for storing the (larger) geometry data associated with `lrrmlra` in a local GeoPackage file created from the official source data
   
  * Added a vignette showing parsed data and graphics of indicator usage areas
  
  * Added basic unit tests
  
  * Added conversion functions: `indicator_to_name()`, `name_to_indicator()`, `indicator_to_usesym()`, `usesym_to_indicator()`, `lrr_to_mlra()`, `mlra_to_lrr()`, `lrr_to_lrrname()`, `lrrname_to_lrr()`, `mlra_to_mlraname()`, `mlraname_to_mlra()`, `lrrmlra_match()`, `fihs_match()`, `usesym_match()`

# Changes in version 0.1.0

## Additions

  * Initial parsing of 'Field Indicators of Hydric Soils in the United States' and storage as internal package dataset called `fhis`
