#' Convert between Land Resource Region (LRR) or Major Land Resource Area (MLRA) Symbols and Names
#'
#' Helper functions for converting between symbols and names associated with Land Resource Regions (LRR) or Major Land Resource Areas (MLRA) using the internal dataset `lrrmlra`.
#'
#' @param x character. Vector LRR or MLRA symbols or names.
#'
#' @return character or list. Vector of LRR or MLRA symbols or names corresponding to `x`.
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
  lrrmlra_match(x, "MLRARSYM")$LRRSYM
}

#' @export
#' @rdname lrrmlra-symbol-conversion
mlra_to_mlraname <- function(x) {
  lrrmlra_match(x, "MLRARSYM")$MLRA_NAME
}

#' @export
#' @rdname lrrmlra-symbol-conversion
mlraname_to_mlra <- function(x) {
  lrrmlra_match(x, "MLRA_NAME")$MLRARSYM
}

#' @param simplify _logical_. If result is a _list_, and `x` is length `1`, return a character vector. Default: `TRUE`
#' @export
#' @rdname lrrmlra-symbol-conversion
lrr_to_mlra <- function(x, simplify = TRUE) {
  if (!is.list(x))
    x <- list(x)
  res <- lapply(x, function(xx) hydricsoils.env$lrrmlra[toupper(hydricsoils.env$lrrmlra[["LRRSYM"]]) %in% toupper(xx), ]$MLRARSYM)
  if (simplify && length(x) == 1) {
    return(res[[1]])
  }
  res
}

#' @export
#' @rdname lrrmlra-symbol-conversion
lrr_to_lrrname <- function(x) {
  lrrmlra_match(x, "LRRSYM")$LRR_NAME
}

#' @export
#' @rdname lrrmlra-symbol-conversion
lrrname_to_lrr <- function(x) {
  lrrmlra_match(x, "LRR_NAME")$LRRSYM
}

#' @param a character. Used only for `lrrmlra_match()`. Column name in `lrrmlra` to match `x` against.
#' @export
#' @rdname lrrmlra-symbol-conversion
lrrmlra_match <- function(x, a) {
  .load_hydricsoils_datasets()
  hydricsoils.env$lrrmlra[match(toupper(x), toupper(hydricsoils.env$lrrmlra[[a]])), ]
}
