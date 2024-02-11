#' Convert between Land Resource Region (LRR) or Major Land Resource Area (MLRA) Symbols and Names
#'
#' Helper functions for converting between symbols and names associated with Land Resource Regions (LRR) or Major Land Resource Areas (MLRA) using the internal dataset `lrrmlra`.
#'
#' @param x character. Vector LRR or MLRA symbols or names.
#'
#' @return character. Vector of LRR or MLRA symbols or names corresponding to `x`.
#' @export
#' @seealso [lrrmlra]
#' @rdname lrrmlra-symbol-conversion
#'
#' @references United States Department of Agriculture, Natural Resources Conservation Service. 2022. Land resource regions and major land resource areas of the United States, the Caribbean, and the Pacific Basin. U.S. Department of Agriculture, Agriculture Handbook 296. Available online: <https://www.nrcs.usda.gov/resources/data-and-reports/major-land-resource-area-mlra>
#'
#' @examples
#'
#' mlra_to_lrr(c("18", "22A"))
#'
#' mlra_to_mlraname("18")
#'
#' mlraname_to_mlra("Sierra Nevada and Tehachapi Mountains")
#'
#' lrr_to_mlra("C")
#'
#' lrr_to_lrrname("D")
#'
#' lrrname_to_lrr("California Subtropical Fruit, Truck, and Specialty Crop Region")
#'
mlra_to_lrr <- function(x) {
  # TODO: match to ensure output conforms with `x` order and NA-handling
  .load_hydricsoils_datasets()
  hydricsoils.env$lrrmlra[hydricsoils.env$lrrmlra$MLRARSYM %in% toupper(x), ]$LRRSYM
}

#' @export
#' @rdname lrrmlra-symbol-conversion
mlra_to_mlraname <- function(x) {
  .load_hydricsoils_datasets()
  hydricsoils.env$lrrmlra[hydricsoils.env$lrrmlra$MLRARSYM %in% toupper(x), ]$MLRA_NAME
}

#' @export
#' @rdname lrrmlra-symbol-conversion
mlraname_to_mlra <- function(x) {
  .load_hydricsoils_datasets()
  hydricsoils.env$lrrmlra[toupper(hydricsoils.env$lrrmlra$MLRA_NAME) %in% toupper(x), ]$MLRARSYM
}

#' @export
#' @rdname lrrmlra-symbol-conversion
lrr_to_mlra <- function(x) {
  .load_hydricsoils_datasets()
  hydricsoils.env$lrrmlra[hydricsoils.env$lrrmlra$LRRSYM %in% toupper(x), ]$MLRARSYM
}

#' @export
#' @rdname lrrmlra-symbol-conversion
lrr_to_lrrname <- function(x) {
  .load_hydricsoils_datasets()
  unique(hydricsoils.env$lrrmlra[hydricsoils.env$lrrmlra$LRRSYM %in% toupper(x), ]$LRR_NAME)
}

#' @export
#' @rdname lrrmlra-symbol-conversion
lrrname_to_lrr <- function(x) {
  .load_hydricsoils_datasets()
  unique(hydricsoils.env$lrrmlra[toupper(hydricsoils.env$lrrmlra$LRR_NAME) %in% toupper(x), ]$LRRSYM)
}
