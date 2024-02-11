# hydricsoils (development version)

* Improvements to the initial parsing routine of `fhis` dataset; cross-checked with appendix and text content of the guide.

* Added usage columns `test_symbols` and `test_except_mlra` to `fihs` dataset indicating where established indicators are being tested

* Added `plot_indicator_usage()` a terra-based graphical method for visualizing the area of applicability of indicators.

* Added `lrrmlra` dataset containing tabular data describing MLRA and LRR symbols and names

* Added `lrrmlra_geometry()` and associated cache-managment methods for storing the (larger) geometry data associated with `lrrmlra` in a local GeoPackage file created from the official source data. 

# hydricsoils (0.1.0)

* Initial parsing of 'Field Indicators of Hydric Soils in the United States' and storage as internal package dataset called `fhis`
