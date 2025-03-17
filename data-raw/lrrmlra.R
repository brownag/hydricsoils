## code to prepare `lrrmlra` dataset goes here
library(terra)

x <- vect(hydricsoils::lrrmlra_geometry_dsn())

## metadata, added as attributes
VERSION <- "5.2"
VERSION_YEAR <- "2022"
REFERENCE <- "United States Department of Agriculture, Natural Resources Conservation Service. 2022. Land resource regions and major land resource areas of the United States, the Caribbean, and the Pacific Basin. U.S. Department of Agriculture, Agriculture Handbook 296. Available online: <https://www.nrcs.usda.gov/resources/data-and-reports/major-land-resource-area-mlra>"


x <- as.data.frame(x)
lrrmlra <- x
if (interactive())
  View(lrrmlra)

attr(lrrmlra, 'version') <- VERSION
attr(lrrmlra, 'version_year') <- VERSION_YEAR
attr(lrrmlra, 'reference') <- REFERENCE
usethis::use_data(lrrmlra, overwrite = TRUE)
