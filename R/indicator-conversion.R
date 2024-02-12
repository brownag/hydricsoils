#' Convert between Indicator Codes, Names and Area Symbols
#'
#' Helper functions for converting between symbols and names associated with hydric indicators, their names, and Land Resource Regions (LRR) or Major Land Resource Areas (MLRA) using the internal dataset `lrrmlra`.
#'
#' @param x character. Vector of indicator codes or names.
#'
#' @return character or list. Vector of indicator codes or names corresponding to `x`.
#' @export
#' @seealso [fihs]
#' @rdname indicator-conversion
#' @importFrom stats setNames
#' @references United States Department of Agriculture, Natural Resources Conservation Service. 2018. Field Indicators of Hydric Soils in the United States, Version 8.2. L.M. Vasilas, G.W. Hurt, and J.F. Berkowitz (eds.). USDA, NRCS, in cooperation with the National Technical Committee for Hydric Soils. Available online: <https://www.nrcs.usda.gov/resources/guides-and-instructions/field-indicators-of-hydric-soils>
#'
#' United States Department of Agriculture, Natural Resources Conservation Service. 2022. Land resource regions and major land resource areas of the United States, the Caribbean, and the Pacific Basin. U.S. Department of Agriculture, Agriculture Handbook 296. Available online: <https://www.nrcs.usda.gov/resources/data-and-reports/major-land-resource-area-mlra>
#'
#' @examples
#'
#' indicator_to_name(c("A11", "A10", NA, "F1", "A8"))
#'
#' name_to_indicator(c("Depleted Below Dark Surface", "2 cm Muck", NA, "Loamy Mucky Mineral", "Muck Presence"))
#'
#' indicator_to_usesym(c("A11", "A10", NA, "F1", "A8"))
#'
#' usesym_to_indicator(c("22A", "150A"))
indicator_to_name <- function(x) {
  fihs_match(x, "indicator")[["indicator_name"]]
}

#' @export
#' @rdname indicator-conversion
name_to_indicator <- function(x) {
  fihs_match(x, "indicator_name")[["indicator"]]
}

#' @param simplify _logical_. If result is a _list_, and `x` is length `1`, return a character vector. Default: `TRUE`
#' @export
#' @rdname indicator-conversion
indicator_to_usesym <- function(x, simplify = TRUE) {
  res <- stats::setNames(fihs_match(x, "indicator")[["usage_symbols"]], x)
  if (simplify && length(x) == 1)
    return(res[[1]])
  res
}

#' @export
#' @rdname indicator-conversion
usesym_match <- function(x) {
  .load_hydricsoils_datasets()
  lul <- hydricsoils.env$fihs$usage_symbols
  names(lul) <- hydricsoils.env$fihs$indicator
  m <- lapply(x, mlra_to_lrr)
  res <- lapply(seq(x), function(i) {
    hydricsoils.env$fihs[sapply(lul, function(y) {
      any(c(m[[i]], x[i]) %in% y, na.rm = TRUE)
    }), ]
  })
  names(res) <- x
  res
}

#' @export
#' @rdname indicator-conversion
usesym_to_indicator <- function(x, simplify = TRUE) {
  .f <- function(y) stats::setNames(lapply(usesym_match(y), `[[`, "indicator"), y)
  if (is.list(x)) {
    res <- lapply(x, function(xx) do.call('intersect', lapply(xx, function(yy) .f(yy)[[1]])))
  } else {
    res <- .f(x)
  }
  if (simplify && length(x) == 1)
    return(res[[1]])
  res
}

#' @param a character. Used only for `fihs_match()`. Column name in `fihs` to match `x` against.
#' @export
#' @rdname indicator-conversion
fihs_match <- function(x, a) {
  .load_hydricsoils_datasets()
  hydricsoils.env$fihs[match(toupper(x), toupper(hydricsoils.env$fihs[[a]])), ]
}

