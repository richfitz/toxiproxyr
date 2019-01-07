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


r6_private <- function(x) {
  environment(x$initialize)$private
}


ping_self <- function(p) {
  tryCatch({
    res <- httr::GET(sprintf("http://%s/version", p$listen))
    httr::stop_for_status(res)
    TRUE
  }, error = function(e) FALSE)
}
