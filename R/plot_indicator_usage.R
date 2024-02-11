#' Plot the Usage Area of a Field Indicator for Hydric Soils
#'
#' @param indicator _character_. The alphanumeric code corresponding to the indicator of interest. For example: `"A12"`
#' @param ext _SpatExtent_, _SpatVector_, _SpatRaster_, or _character_. Either a terra object that can be converted to SpatExtent. Alternately, a _character_ vector denoting the usage constraints (one or more of `"Approved"`, `"Excluded"`, or `"Testing"`). The resulting _SpatExtent_ is passed as the `ext` argument of `terra::plot()`.
#' @param plg _list_. Passed as `plg` argument of `terra::plot()`.
#' @param crs _character_. Optional: target coordinate reference system to project `lrrmlra_geometry()` result to. Default: `NULL` uses the `"OGC:CRS84"` geographic coordinate system.
#' @param test_areas _logical_. Show areas where indicator is being tested? Default: `FALSE`
#' @param overwrite _logical_. Passed to `lrrmlra_geometry()`. Default: `FALSE`
#' @param dsn _character_. Passed to `lrrmlra_geometry()`. Default: `NULL` uses the default remote source via GDAL Virtual File System.
#'
#' @return This function is called for the side effect of creating output on the graphics pane.
#' @export
#' @importFrom grDevices hcl.colors
#' @examplesIf !inherits(try(requireNamespace("terra", quietly = TRUE), silent = TRUE), 'try-error')
#'
#' par(mfrow = c(2, 1))
#' plot_indicator_usage("A5", test_areas = TRUE, ext = c("Approved", "Excluded"))
#' plot_indicator_usage("A9", test_areas = TRUE, ext = c("Approved", "Excluded"))
plot_indicator_usage <- function(indicator,
                                 ext = NULL,
                                 plg = NULL,
                                 crs = NULL,
                                 test_areas = FALSE,
                                 overwrite = FALSE,
                                 dsn = NULL) {

  .load_hydricsoils_datasets()

  # TODO: multiple indicators? intersection? custom symbology?
  stopifnot(length(indicator) == 1)
  indicator <- toupper(trimws(indicator))

  # TODO: custom colors and legend labels
  leglab <- c("Approved", "Excluded", "Testing")
  legcol <- grDevices::hcl.colors(3)

  x <- lrrmlra_geometry(overwrite = overwrite, dsn = dsn)

  if (!is.null(crs)) {
    x <- terra::project(x, crs)
  }

  ind <- hydricsoils.env$fihs[hydricsoils.env$fihs$indicator %in% indicator, ]

  use <- unlist(ind$usage_symbols)
  tst <- unlist(ind$test_symbols)

  exc <- unlist(ind$except_mlra)

  xsub <- terra::subset(x, (x$LRRSYM %in% use | x$MLRARSYM %in% use) & !x$MLRARSYM %in% exc)

  # TODO: custom symbol for excepted test areas? lumped for now
  if (test_areas) {
    exc <- c(exc, unlist(ind$test_except_mlra))
  }

  xtst <- terra::subset(x, (x$LRRSYM %in% tst | x$MLRARSYM %in% tst) & !x$MLRARSYM %in% exc)

  # TODO: are/will whole LRRs ever be excepted?
  xexc <- terra::subset(x, x$MLRARSYM %in% exc | x$LRRSYM %in% exc)

  # create combined SpatVector with symbology column
  xsub$.internalUsageCategory <- "Approved"
  xexc$.internalUsageCategory <- "Excluded"
  xcmb <- rbind(xsub, xexc)

  if (test_areas) {
    xtst$.internalUsageCategory <- "Testing"
    xcmb <- rbind(xcmb, xtst)
  }

  if (is.null(ext)) {
    xext <- xcmb
  } else {
    if (is.character(ext)) {
      ext <- tolower(trimws(ext))
      xext <- xsub[0, ]
      if ("approved" %in% ext) {
        xext <- rbind(xext, xsub)
      }
      if ("excluded" %in% ext) {
        xext <- rbind(xext, xexc)
      }
      if ("testing" %in% ext) {
        xext <- rbind(xext, xtst)
      }
    } else {
      xext <- ext
    }
  }

  if (nrow(xsub)) {
    # base plot is all MLRA lines
    terra::plot(x, ext = xext)

    # handle an empty extent/conditions that have no geometry visible
    if (all(terra::ext(xext)[1:4] == 0)) {
      stop("Selected extent has no data", call. = FALSE)
    }

    if (nrow(xcmb)) {
      terra::plot(
        xcmb,
        ".internalUsageCategory",
        ext = xext,
        add = TRUE,
        main = paste0(ind$indicator, " -- ", ind$indicator_name),
        col = legcol[match(unique(xcmb$.internalUsageCategory), leglab)],
        plg = plg
      )
    }
  } else stop("Indicator '", indicator, "' not found.", call. = FALSE)
}
