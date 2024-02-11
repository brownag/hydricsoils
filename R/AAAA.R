hydricsoils.env <- new.env()
utils::globalVariables(c("fihs", "lrrmlra"), package = "hydricsoils")

#' @importFrom utils globalVariables packageVersion
.onAttach <- function(libname, pkgname) {
  packageStartupMessage("hydricsoils v",
                        utils::packageVersion(pkgname, libname),
                        " -- using:")

  .load_hydricsoils_datasets()

  packageStartupMessage(" - 'Field Indicators of Hydric Soils in the United States' v",
                        attr(hydricsoils.env$fihs, 'version'), " (",
                        attr(hydricsoils.env$fihs, 'version_year'), ")")
  packageStartupMessage(" - 'Land Resource Regions and Major Land Resource Areas of the United States, the Caribbean, and the Pacific Basin' v",
                        attr(hydricsoils.env$lrrmlra, 'version'), " (",
                        attr(hydricsoils.env$lrrmlra, 'version_year'), ")")
}

.load_hydricsoils_datasets <- function() {
  if (is.null(hydricsoils.env$fihs)) {
    fihs <- NULL
    load(system.file("data", "fihs.rda", package = "hydricsoils"))
    hydricsoils.env$fihs <- fihs
  }

  if (is.null(hydricsoils.env$lrrmlra)) {
    lrrmlra <- NULL
    load(system.file("data", "lrrmlra.rda", package = "hydricsoils"))
    hydricsoils.env$lrrmlra <- lrrmlra
  }

  invisible(!is.null(hydricsoils.env$fihs) && !is.null(hydricsoils.env$lrrmlra))
}
