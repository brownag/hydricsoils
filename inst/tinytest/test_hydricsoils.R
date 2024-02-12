data(fihs, package = "hydricsoils")

has_terra_and_spatial <- !inherits(try(requireNamespace("terra", quietly = TRUE), silent = TRUE), 'try-error') && file.exists(file.path(tools::R_user_dir("hydricsoils", "data"), "lrrmlra.gpkg"))

# basic checks on parsing of FIHS ----
expect_equal(nrow(fihs), 44)

# Indicator A9 "1 cm Muck"  ----
# - several LRRs in use, with an exception
# - testing in several LRRs
a9 <- subset(fihs, indicator == "A9")
expect_equal(a9$page, "13")
expect_equal(a9$usage_symbols[[1]], c("D", "F", "G", "H", "P", "T"))
expect_equal(a9$except_mlra[[1]], "136")
expect_equal(a9$test_symbols[[1]], c("C", "I", "J", "O"))

# Indicator A13 "Alaska Gleyed" ----
# - approved in FIHS2018 for use in Alaska (W, X, Y LRRs)
# - in MLRA2022 database we have W1, W2, X1, X2, and Y LRRs
a13 <- subset(fihs, indicator == "A13")
expect_equal(a13$page, "16")
expect_equal(a13$usage_symbols[[1]], c("W1", "W2", "X1", "X2", "Y"))
expect_equal(a13$except_mlra[[1]], character(0))
expect_equal(a13$test_symbols[[1]], character(0))
expect_equal(a13$test_except_mlra[[1]], character(0))

# Indicator A16 "Coast Prairie Redox" ----
# - approved for use in one MLRA
# - tested in one LRR (except for one MLRA)
a16 <- subset(fihs, indicator == "A16")
expect_equal(a16$page, "17")
expect_equal(a16$usage_symbols[[1]], c("150A"))
expect_equal(a16$except_mlra[[1]], character(0))
expect_equal(a16$test_symbols[[1]], c("S"))
expect_equal(a16$test_except_mlra[[1]], "149B")

# conversions ----

## indicator to name ----
expect_equal(indicator_to_name(c("A11", "A10", NA, "F1", "A8")),
             c("Depleted Below Dark Surface", "2 cm Muck", NA, "Loamy Mucky Mineral", "Muck Presence"))

## name to indicator ----
expect_equal(name_to_indicator(c("Depleted Below Dark Surface", "2 cm Muck", NA, "Loamy Mucky Mineral", "Muck Presence")),
             c("A11", "A10", NA, "F1", "A8"))

## indicator to usesym
expect_equal(indicator_to_usesym(c("A11", "A10", NA, "F1", "A8")),
             structure(list(c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "Z"), c("M", "N"), NULL, c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "O"), c("Q", "U", "V", "Z")), names = c("A11", "A10", NA, "F1", "A8")))

## usesym to indicator (by symbol)
expect_equal(usesym_to_indicator(c("18", "150A")),
             list(`18` = c("A1", "A2", "A3", "A4", "A5", "A11", "A12", "S1", "S4", "S5", "S6", "F1", "F2", "F3", "F6", "F7", "F8"),
                  `150A` = c("A1", "A2", "A3", "A4", "A5", "A6", "A7", "A9", "A11", "A12", "A16", "S4", "S5", "S6", "S7", "S8", "S9", "F2", "F3", "F6", "F7", "F8","F13", "F18")))

## usesym to indicator (multisymbol)
# gives indicators used in BOTH 18 and 150A
expect_equal(usesym_to_indicator(list(c("18", "150A"))),
             intersect(usesym_to_indicator("18"), usesym_to_indicator("150A")))

## 1:1 conversions of MLRA:MLRA, MLRA:LRR, LRR:LRR
expect_equal(mlra_to_lrr(c("18", "22A")), c("C", "D"))
expect_equal(mlra_to_mlraname("18"), "Sierra Nevada Foothills")
expect_equal(mlraname_to_mlra("Sierra Nevada and Tehachapi Mountains"), "22A")
expect_equal(lrr_to_mlra("C"), as.character(14:19))
expect_equal(lrr_to_mlra(list(c("C", "D"))), c(lrr_to_mlra("C"), lrr_to_mlra("D")))
expect_equal(lrr_to_lrrname("D"), "Western Range and Irrigated Region")
expect_equal(lrrname_to_lrr("California Subtropical Fruit, Truck, and Specialty Crop Region"), "C")

# terra-based plotting
if (has_terra_and_spatial) {
  # gulf coast area
  expect_silent(plot_indicator_usage("A16"))

  # gulf coast to long island
  expect_silent(plot_indicator_usage("A16", test_areas = TRUE, crs = "EPSG:5070"))
} else message("\n\nNOTICE: skipped terra/plot tests\n\n")
