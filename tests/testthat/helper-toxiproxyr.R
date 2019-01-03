has_internet <- function() {
  !is.null(suppressWarnings(utils::nsl("www.google.com")))
}


skip_if_no_internet <- function() {
  testthat::skip_on_cran()
  if (has_internet()) {
    return()
  }
  testthat::skip("no internet")
}
