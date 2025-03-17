#' DATA: 'Field Indicators of Hydric Soils in the United States'
#'
#' This dataset is derived from the latest edition of the ['Field Indicators of Hydric Soils in the United States' (Version 9.0, 2024)](https://www.nrcs.usda.gov/sites/default/files/2024-09/Field-Indicators-of-Hydric-Soils.pdf)
#'
#' @usage data(fihs)
#' @keywords datasets
#' @references United States Department of Agriculture, Natural Resources Conservation Service. 2018. Field Indicators of Hydric Soils in the United States, Version 8.2. L.M. Vasilas, G.W. Hurt, and J.F. Berkowitz (eds.). USDA, NRCS, in cooperation with the National Technical Committee for Hydric Soils. Available online: <https://www.nrcs.usda.gov/resources/guides-and-instructions/field-indicators-of-hydric-soils>
"fihs"

#' DATA: 'Land Resource Regions and Major Land Resource Areas of the United States, the Caribbean, and the Pacific Basin'
#'
#' This dataset is derived from the latest edition of the ['MLRA Geographic Database' (Version 5.2, 2022)](https://www.nrcs.usda.gov/sites/default/files/2022-10/MLRA_52_2022.zip)
#'
#' @usage data(lrrmlra)
#' @keywords datasets
#' @references United States Department of Agriculture, Natural Resources Conservation Service. 2022. Land resource regions and major land resource areas of the United States, the Caribbean, and the Pacific Basin. U.S. Department of Agriculture, Agriculture Handbook 296. Available online: <https://www.nrcs.usda.gov/resources/data-and-reports/major-land-resource-area-mlra>
"lrrmlra"

#' hydricsoils Data Directory
#' @returns `hydricsoils_data_dir()`: character. Path to hydricsoil package user
#'   data directory. Default: `tools::R_user_dir("hydricsoils", which = "data")`
#' @export
#' @examples
#'
#' hydricsoils_data_dir()
#'
hydricsoils_data_dir <- function() {
  tools::R_user_dir("hydricsoils", which = "data")
}
