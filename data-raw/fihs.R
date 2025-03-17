## code to prepare `fihs` dataset goes here
# download.file("https://www.nrcs.usda.gov/sites/default/files/2024-09/Field-Indicators-of-Hydric-Soils.pdf",
#               destfile = "FIHS.pdf", mode = "wb")
# system("pdftotext -raw -nodiag FIHS.pdf FIHS.txt")

# # remove figure captions manually
x <- readLines("inst/extdata/FIHS.txt", warn = FALSE)
f <- readLines("inst/extdata/FIGS.txt", warn = FALSE)

# clean FIGS
cat(trimws(strsplit(paste0(f, collapse = " "), "—")[[1]]), file = "inst/extdata/FIGS.txt", sep = "\n")

f <- readLines("inst/extdata/FIGS.txt", warn = FALSE)


## metadata, added as attributes
VERSION <- "9.0"
VERSION_YEAR <- "2024"
REFERENCE <- "United States Department of Agriculture, Natural Resources Conservation Service. 2024. Field Indicators of Hydric Soils in the United States, Version 9.0. Available online: <https://www.nrcs.usda.gov/resources/guides-and-instructions/field-indicators-of-hydric-soils>"

#
##
## something like this might be able to automate:
##
# fd <- pdftools::pdf_data("FIHS.pdf", font_info = TRUE)
# fd <- do.call('rbind', fd)
# fd <- subset(fd, !(font_name == "Helvetica-Bold" & font_size == 8))
##
## somehow rebuild suitable text vector from `fd` ...
##
idx <- grep("^Introduction$|^All Soils$|^Sandy Soils$|^Loamy and Clayey Soils$|Test Indicators of Hydric Soils$|^References$", x)
idx <- idx[4:8]
x <- gsub("(for use in all LRRs) or Histel (for", "or Histel. ", x, fixed = TRUE)
x <- gsub("use in LRRs with permafrost). ", "", x, fixed = TRUE)
x <- gsub("from12 to18 percent", "from 12 to 18 percent", x)
x <- gsub("dune-and- swale", "dune-and-swale", x)
x <- gsub("T, U, W, X, Y , and Z", "T, U, W, X, Y, and Z", x)
x <- gsub("\\b([a-f])\\. ", "(\\1) ", x)
x <- gsub("fig(s*)\\.", "Figure\\1", x)
x[grep("A1.\u2014", x) + 1]
sec.idx <- c(idx - 1, length(x))
sec.len <- diff(c(0, sec.idx))
sec.lbl <- c("Field Indicators of Hydric Soils",
             "Front Matter",
             "All Soils", "Sandy Soils", "Loamy and Clayey Soils",
             # "Test Indicators",
             # "All Soils (Test)", "Sandy Soils (Test)", "Loamy and Clayey Soils (Test)",
             "End Matter")
page.idx <- grep("^\\f+", x)
page.len <- diff(c(0, page.idx))
page.num <- gsub("^\\f+([0-9iv]+).*(Hydric Soils|Field Indicators of)?", "\\1", x[page.idx])
page.idx <- page.idx - 1
page.num[1] <- "i"
page.num[40] <- "36"
page.num[55] <- "52"
page.num <- gsub("\\f", "", page.num)

# break out page numbers and sections for each line of content
d <- data.frame(
  row = seq(length(x)),
  page = unlist(sapply(seq(page.num), function(i) {
    rep(page.num[i], page.len[i])
  })),
  section = unlist(sapply(seq(sec.lbl), function(i) {
    rep(sec.lbl[i], sec.len[i])
  })),
  content = x
)

# remove page numbers, headers, form feed
p.idx.keep <- grep("^\\f+([0-9iv]+).*(Hydric Soils|Field Indicators of)?", x, invert = TRUE)
d <- d[p.idx.keep,]

d2 <- split(d, factor(d$section, levels = unique(d$section)))


parseIndicator <- function(x) {
  un.idx <- grep("^User Notes:", x$content)[1]
  if (!is.na(un.idx)) {
    bi <- 1:(un.idx - 1)
    un <- un.idx:length(x$content)
  } else {
    bi <- seq(x$content)
    un <- 0
  }
  res <- cbind(x[1, c("section", "indicator")], data.frame(
    body = I(list(trimws(strsplit(paste0(x$content[bi], collapse = " "), "\\. ")[[1]]))),
    note = I(list(trimws(paste0(x$content[un], collapse = " ")))),
    indicator = x$indicator[1],
    indicator_name = gsub("(.*)\\. For use in.*", "\\1", x$indicator_name[1]),
    page = x$page[1]
  ))
  rownames(res) <- NULL
  res
}

dout <- do.call('rbind', lapply(d2, function(dd) {
  ind.idx <- grep("([ASFT]+\\d+).\u2014([0-9A-Za-z \\.]*)\\. ", dd$content)
  indicators <- do.call('rbind', strsplit(gsub("([ASFT]+\\d+).\u2014([\\(\\)0-9A-Za-z \\.]*)\\. .*", "\\1;\\2;",
                                               dd$content[ind.idx]), ";"))
  ind.len <- diff(c(0, c(ind.idx - 1, length(dd$content))))
  ind.lbl <- c(dd$section[1], indicators[, 1])
  ind.nam <- c(dd$section[1], indicators[, 2])

  dd$content[ind.idx] <- gsub("[ASFT]+\\d+.\u2014[\\(\\)0-9A-Za-z \\.]*\\. (.*)", "\\1", dd$content[ind.idx])
  dd$indicator <- unlist(sapply(seq(ind.lbl), function(i) {
    rep(ind.lbl[i], ind.len[i])
  }))
  dd$indicator_name <- unlist(sapply(seq(ind.nam), function(i) {
    rep(ind.nam[i], ind.len[i])
  }))

  d3 <- split(dd, factor(dd$indicator, levels = unique(dd$indicator)))
  d4 <- lapply(d3, parseIndicator)
  d5 <- do.call('rbind', d4)
  d5
}))
rownames(dout) <- NULL

dout$usage <- sapply(dout$body, \(z) ifelse(grepl("^For use (in|along)", z[[1]]), z[[1]], ""))
dout$criteria <- sapply(dout$body, \(z) na.omit(z[2:length(z)]))

# fix for F21 (misuse of semicolons)
dout$usage <- gsub("For use in MLRA 127 of LRR N; MLRA 145 of LRR R; and MLRAs 147 and 148 of LRR S;", "For use in MLRA 127 of LRR N, MLRA 145 of LRR R, and MLRAs 147 and 148 of LRR S;", dout$usage)

dout$usage <- gsub("[^;]( for testing in)", ";\\1", dout$usage)
dout$usage[dout$usage == ""] <- "For use in all LRRs"
dout$usage_symbols <- gsub("For use[^;]*in LRRs* ([^;]*);*.*$", "\\1", dout$usage)
dout$usage_symbols <- gsub(",* and ([A-Z])", ", \\1", dout$usage_symbols)

## fix for S1
dout$usage_symbols <- gsub("and portions of LRR P outside of MLRA 136",
                           "(except for MLRAs 133A, 133B, 133C, 134, 135A, 135B, 136, 137, and 138)",
                           dout$usage_symbols)

# fix for F1
dout$usage_symbols <- gsub("those using A7 (LRRs P, T, U, Z), MLRA 1 of LRR A",
                           "P, T, U, Z", dout$usage_symbols, fixed = TRUE)

# fix for F13
dout$usage_symbols <- gsub("MLRA 122 of LRR N", "122", dout$usage_symbols)

# fix for F18
dout$usage_symbols <- gsub("150\\b", "150A, 150B", dout$usage_symbols)

dout$except_mlra <- gsub(".*\\(except for MLRAs* (.*)\\).*|.*", "\\1", dout$usage_symbols)
dout$except_mlra <- gsub(",* and ", ", ", dout$except_mlra)

# fix for F1
dout$except_mlra[which(dout$indicator == "F1")] <- "1"

dout$except_mlra <- lapply(strsplit(dout$except_mlra, ","), trimws)
dout$usage_symbols <- gsub("(.*)\\(except for MLRAs* .*\\)(.*)", "\\1\\2", dout$usage_symbols)

dout$except_lrrsymbols1 <- gsub("For use in all LRRs, except [for ]*([^;]*).*|.*", "\\1", dout$usage_symbols)
dout$usage_symbols <- gsub("For use in all LRRs.*", paste0(LETTERS, collapse = ", "), dout$usage_symbols)

dout$usage_mlras <- gsub("and", ",", gsub("of LRR [A-Z]|in|MLRAs*|West Florida portions of|;.*", "", gsub("For use in MLRAs*(.*)|.*", "\\1", dout$usage_symbols)))

# convert to split Alaska LRRs for 2022 spatial
dout$usage_symbols <- gsub("W, X", "W1, W2, X1, X2", dout$usage_symbols)
dout$except_lrrsymbols1 <- gsub("W, X", "W1, W2, X1, X2", dout$except_lrrsymbols1)

dout$usage_symbols <- sapply(strsplit(dout$usage_symbols, ","), trimws)
dout$except_lrrsymbols1 <- sapply(strsplit(dout$except_lrrsymbols1, ","), trimws)
dout$usage_mlras <- sapply(strsplit(dout$usage_mlras, ","), trimws)

mlra.spec.idx <- sapply(dout$usage_mlras, length) > 0
dout$usage_symbols[mlra.spec.idx] <- dout$usage_mlras[mlra.spec.idx]

for (u in seq(dout$usage_symbols)) {
  dout$usage_symbols[[u]] <- setdiff(dout$usage_symbols[[u]], dout$except_lrrsymbols1[[u]])
}

# subset(dout, grepl("; for testing", dout$usage), select = c(indicator, usage))

dout$test_symbols <- gsub(".*; for testing [io]n (.*)$|.*", "\\1", dout$usage)
dout$test_except_mlra <- gsub(".*\\(except for MLRAs* (.*)\\).*|.*", "\\1", dout$test_symbols)
dout$test_symbols <- gsub("(.*)\\(except for MLRAs* .*\\).*|(.*)", "\\1\\2", dout$test_symbols)
dout$test_symbols <- gsub("(^MLRAs*|^LRRs*|^other MLRAs of LRR| of LRR [A-Z]|^flood plains subject to Piedmont deposition throughout LRRs )",
                          "", dout$test_symbols)
dout$test_symbols <- gsub("^all.*", "All other LRRs", dout$test_symbols)
dout$test_symbols <- trimws(gsub(",* and ", ", ", dout$test_symbols))

test.all.other.idx <- grep("All other LRRs", dout$test_symbols)
for (i in test.all.other.idx) {
  dout$test_symbols[i] <- paste0(LETTERS[!LETTERS %in% dout$usage_symbols[i][[1]]], collapse = ", ")
}

# convert to split Alaska LRRs for 2022 spatial
dout$test_symbols <- gsub("W, X", "W1, W2, X1, X2", dout$test_symbols)

dout$test_symbols <- lapply(strsplit(dout$test_symbols, ","), trimws)
dout$test_except_mlra <- lapply(strsplit(dout$test_except_mlra, ","), trimws)

# remove testing exceptions from approved exceptions
dout$except_mlra <- lapply(seq(dout$except_mlra), function(i) {
  dout$except_mlra[[i]][!dout$except_mlra[[i]] %in% dout$test_except_mlra[[i]]]
})

# subset(dout, grepl("; for testing", dout$usage), select = c(indicator, usage, test_symbols))


dout$criteria <- sapply(dout$criteria, paste0, collapse = ". \n")
dout$criteria <- gsub("  ", " ", dout$criteria)
dout$criteria <- gsub("\\.\\.", ".", dout$criteria)

fihs <- dout
fihs[[2]] <- NULL
fihs$body <- NULL

fihs <- subset(fihs, grepl( "T*[ASF]\\d+", fihs$indicator))

replaceUnicodeChars <- function(x) {
  gsub("\u2264", "<=", x) |>
    gsub("\u2265", ">=", x = _) |>
    gsub("\u201c|\u201d", "\"", x = _)
}

fihs$criteria <- stringi::stri_enc_toascii(replaceUnicodeChars(fihs$criteria))
fihs$note <- stringi::stri_enc_toascii(replaceUnicodeChars(fihs$note))

fihs_test <- subset(fihs, grepl("(Test)", fihs$section))
fihs <- subset(fihs, !grepl("(Test)", fihs$section))
fihs <- fihs[c("section", "indicator", "indicator_name", "page",
               "usage", "usage_symbols", "except_mlra", "test_symbols", "test_except_mlra",
               "criteria", "note")]

if (interactive())
  View(fihs)
fihs <- fihs[-1,]
rownames(fihs) <- NULL
attr(fihs, 'version') <- VERSION
attr(fihs, 'version_year') <- VERSION_YEAR
attr(fihs, 'reference') <- REFERENCE
fihs90 <- fihs
usethis::use_data(fihs, overwrite = TRUE)

## TODO: fihs_test dataset; need to confirm where they are being tested
## TODO: splice in existing indicators that have testing LRRs? or add additonal column to fihs
# usethis::use_data(fihs_test, overwrite = TRUE)
