data(fihs, package = "hydricsoils")

has_terra_and_spatial <- !inherits(try(requireNamespace("terra", quietly = TRUE), silent = TRUE), 'try-error') && file.exists(file.path(tools::R_user_dir("hydricsoils", "data"), "lrrmlra.gpkg"))

# basic checks on parsing of FIHS
expect_equal(nrow(fihs), 44)

# Indicator A9 "1 cm Muck" has several LRRs in use, with an exception, and testing in several LRRs
a9 <- subset(fihs, indicator == "A9")
expect_equal(a9$page, "13")
expect_equal(a9$usage_symbols[[1]], c("D", "F", "G", "H", "P", "T"))
expect_equal(a9$except_mlra[[1]], "136")
expect_equal(a9$test_symbols[[1]], c("C", "I", "J", "O"))

# Indicator A13 "Alaska Gleyed" is
# - approved in FIHS2018 for use in Alaska (W, X, Y LRRs)
# - in MLRA2022 database we have W1, W2, X1, X2, and Y LRRs
a13 <- subset(fihs, indicator == "A13")
expect_equal(a13$page, "16")
expect_equal(a13$usage_symbols[[1]], c("W1", "W2", "X1", "X2", "Y"))
expect_equal(a13$except_mlra[[1]], character(0))
expect_equal(a13$test_symbols[[1]], character(0))
expect_equal(a13$test_except_mlra[[1]], character(0))

# Indicator A16 "Coast Prairie Redox" is
# - approved for use in one MLRA
# - tested in one LRR (except for one MLRA)
a16 <- subset(fihs, indicator == "A16")
expect_equal(a16$page, "17")
expect_equal(a16$usage_symbols[[1]], c("150A"))
expect_equal(a16$except_mlra[[1]], character(0))
expect_equal(a16$test_symbols[[1]], c("S"))
expect_equal(a16$test_except_mlra[[1]], "149B")

# conversions
expect_equal(mlra_to_lrr(c("18", "22A")), c("C", "D"))

expect_equal(mlra_to_mlraname("18"), "Sierra Nevada Foothills")

expect_equal(mlraname_to_mlra("Sierra Nevada and Tehachapi Mountains"), "22A")

expect_equal(lrr_to_mlra("C"), as.character(14:19))

expect_equal(lrr_to_lrrname("D"), "Western Range and Irrigated Region")

expect_equal(lrrname_to_lrr("California Subtropical Fruit, Truck, and Specialty Crop Region"), "C")

# terra-based plotting
if (has_terra_and_spatial) {
  # gulf coast area
  expect_silent(plot_indicator_usage("A16"))

  # gulf coast to long island
  expect_silent(plot_indicator_usage("A16", test_areas = TRUE, crs = "EPSG:5070"))
} else message("\n\nNOTICE: skipped terra/plot tests\n\n")
