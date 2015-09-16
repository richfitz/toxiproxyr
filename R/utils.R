vlapply <- function(X, FUN, ...) {
  vapply(X, FUN, logical(1), ...)
}
vcapply <- function(X, FUN, ...) {
  vapply(X, FUN, character(1), ...)
}

##' @importFrom jsonlite toJSON
to_json <- function(x) {
  jsonlite::toJSON(x, auto_unbox=TRUE)
}

assert_response <- function(response) {
  httr::stop_for_status(response)
}

assert_logical <- function(x, name=deparse(substitute(x))) {
  if (!is.logical(x)) {
    stop(sprintf("%s must be logical", name), call.=FALSE)
  }
}
assert_character <- function(x, name=deparse(substitute(x))) {
  if (!is.character(x)) {
    stop(sprintf("%s must be character", name), call.=FALSE)
  }
}

assert_scalar <- function(x, name=deparse(substitute(x))) {
  if (length(x) != 1) {
    stop(sprintf("%s must be a scalar", name), call.=FALSE)
  }
}

assert_scalar_logical <- function(x, name=deparse(substitute(x))) {
  assert_scalar(x, name)
  assert_logical(x, name)
}
assert_scalar_character <- function(x, name=deparse(substitute(x))) {
  assert_scalar(x, name)
  assert_character(x, name)
}

assert_named <- function(x,
                         empty_can_be_unnamed=TRUE,
                         unique_names=TRUE,
                         name=deparse(substitute(x))) {
  nx <- names(x)
  if (is.null(nx) || any(nx == "")) {
    if (length(x) > 0 || !empty_can_be_unnamed) {
      stop(sprintf("%s must be named", name), call.=FALSE)
    }
  } else if (unique_names && any(duplicated(nx))) {
    stop(sprintf("%s must have unique names", name), call.=FALSE)
  }
}

assert_inherits <- function(x, what, name=deparse(substitute(x))) {
  if (!inherits(x, what)) {
    stop(sprintf("%s must be a %s", name,
                 paste(what, collapse=" / ")), call.=FALSE)
  }
}

is_socket_open <- function(host, port) {
  res <- try(close(suppressWarnings(socketConnection(host, port))),
             silent=TRUE)
  if (inherits(res, "try-error")) {
    FALSE
  } else {
    TRUE
  }
}

match_value <- function(arg, choices, name=deparse(substitute(arg))) {
  assert_scalar_character(arg)
  if (!(arg %in% choices)) {
    stop(sprintf("%s must be one of %s",
                 name, paste(dQuote(choices), collapse=", ")))
  }
  arg
}

assert_direction <- function(direction) {
  match_value(direction, c("upstream", "downstream"))
}

## Pattern where we have a named list and we want to call function
## 'FUN' with rather than just
##    {FUN(X[[1]], ...), ..., FUN(X[[n]], ...)}
## instead as
##    {FUN{names(X)[1], X[[1]], ...}, ..., names(X)[1], X[[1]], ...}
## this can be achived via mapply, but it's not pleasant.
lnapply <- function(X, FUN, ...) {
  nX <- names(X)
  res <- lapply(seq_along(X), function(i) FUN(nX[[i]], X[[i]], ...))
  names(res) <- nX
  res
}
