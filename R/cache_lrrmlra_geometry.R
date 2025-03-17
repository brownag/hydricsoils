#' Download and Cache or Load Latest 'MLRA Geographic Database'
#'
#' Creates a local copy of the latest 'MLRA Geographic Database' in the user's package data cache. This file/directory is separate from the package installation.
#'
#' @param overwrite Overwrite existing file? Passed to `terra::writeVector()`. Default: `FALSE`
#' @param dsn Path to a geospatial data source. Default path uses GDAL Virtual File Systems to access and decompress remote source (`"/vsizip//vsicurl/https://www.nrcs.usda.gov/sites/default/files/2022-10/MLRA_52_2022.zip/MLRA_52_2022"`).
#'
#' @return `cache_lrrmlra_geometry()`: logical. Called for the side-effect of adding the MLRA geometry file to the cache. Returns `TRUE` if the `"lrrmlra.gpkg"` file exists in the user's `"data"` cache directory.
#' @export
#' @seealso [lrrmlra]
#' @source The default source is a ZIP file containing an ESRI Shapefile. The direct download URL is <https://www.nrcs.usda.gov/sites/default/files/2022-10/MLRA_52_2022.zip>, which can be found [here](https://www.nrcs.usda.gov/resources/data-and-reports/major-land-resource-area-mlra).
#'
#' @references United States Department of Agriculture, Natural Resources Conservation Service. 2022. Land resource regions and major land resource areas of the United States, the Caribbean, and the Pacific Basin. U.S. Department of Agriculture, Agriculture Handbook 296. Available online: <https://www.nrcs.usda.gov/resources/data-and-reports/major-land-resource-area-mlra>
#' @rdname lrrmlra-geometry
#'
#' @examples
#' \dontrun{
#'  library(terra)
#'
#'  # download (if needed) and load geometry
#'  x <- lrrmlra_geometry()
#'  plot(x)
#'
#'  # clear cache
#'  clear_lrrmlra_geometry()
#'
#'  # download and cache (without loading)
#'  cache_lrrmlra_geometry()
#' }
#'
cache_lrrmlra_geometry <- function(overwrite = FALSE,
                                   dsn = lrrmlra_geometry_dsn()) {

  if (is.null(dsn)) {
    dsn <- lrrmlra_geometry_dsn()
  }

  fp <- file.path(hydricsoils_data_dir(), "lrrmlra.gpkg")

  if (!requireNamespace("terra")) {
    stop("package 'terra' is required to create local MLRA Geographic Database cache")
  }

  if (!dir.exists(dirname(fp))) {
    dir.create(dirname(fp), showWarnings = FALSE, recursive = TRUE)
  }

  if (!file.exists(fp) || overwrite) {
    lrrmlrageom <- terra::vect(dsn)
    terra::writeVector(lrrmlrageom, filename = fp, overwrite = overwrite)
  }

  invisible(file.exists(fp))
}

#' @export
#' @rdname lrrmlra-geometry
#' @return `clear_lrrmlra_geometry()`: logical. Called for the side-effect of removing the MLRA geometry file from the cache. Returns `TRUE` if `"lrrmlra.gpkg"` is successfully removed from user data cache.
clear_lrrmlra_geometry <- function() {
  invisible(
    file.remove(
      file.path(hydricsoils_data_dir(), "lrrmlra.gpkg")
    )
  )
}

#' @export
#' @rdname lrrmlra-geometry
#' @return `lrrmlra_geometry()`: A terra _SpatVector_ object containing `lrrmlra` attributes and geometry.
lrrmlra_geometry <- function(overwrite = FALSE,
                             dsn = lrrmlra_geometry_dsn()) {
  if (cache_lrrmlra_geometry(overwrite = overwrite, dsn = dsn)) {
    return(terra::vect(
      file.path(hydricsoils_data_dir(), "lrrmlra.gpkg")
    ))
  }
}

#' @export
#' @rdname lrrmlra-geometry
#' @return `lrrmlra_geometry_dsn()`: character. Path to MLRA Geographic Database source.
lrrmlra_geometry_dsn <- function() {
  # "https://www.nrcs.usda.gov/sites/default/files/2022-10/MLRA_52_2022.zip/MLRA_52_2022"
  "/vsizip//vsicurl/https://s3-fpac-nrcs-dshub-public.s3.us-gov-west-1.amazonaws.com/MLRA_52_2022.zip"
}
