assert_scalar <- function(x, name = deparse(substitute(x))) {
  if (length(x) != 1) {
    stop(sprintf("'%s' must be a scalar", name), call. = FALSE)
  }
  invisible(x)
}


assert_integer <- function(x, strict = FALSE, name = deparse(substitute(x)),
                           what = "integer") {
  if (!(is.integer(x))) {
    usable_as_integer <-
      !strict && is.numeric(x) && (max(abs(round(x) - x)) < 1e-8)
    if (!usable_as_integer) {
      stop(sprintf("'%s' must be %s", name, what), call. = FALSE)
    }
  }
  invisible(x)
}


assert_numeric <- function(x, name = deparse(substitute(x))) {
  if (!is.numeric(x)) {
    stop(sprintf("'%s' must be numeric", name), call. = FALSE)
  }
  invisible(x)
}


assert_character <- function(x, name = deparse(substitute(x))) {
  if (!is.character(x)) {
    stop(sprintf("'%s' must be a character", name), call. = FALSE)
  }
  invisible(x)
}


assert_logical <- function(x, name = deparse(substitute(x))) {
  if (!is.logical(x)) {
    stop(sprintf("'%s' must be a logical", name), call. = FALSE)
  }
  invisible(x)
}


assert_scalar_logical <- function(x, name = deparse(substitute(x))) {
  assert_scalar(x, name)
  assert_logical(x, name)
}


assert_scalar_integer <- function(x, strict = FALSE,
                                  name = deparse(substitute(x))) {
  assert_scalar(x, name)
  assert_integer(x, strict, name)
}


assert_scalar_numeric <- function(x, name = deparse(substitute(x))) {
  assert_scalar(x, name)
  assert_numeric(x, name)
}


assert_scalar_character <- function(x, name = deparse(substitute(x))) {
  assert_scalar(x, name)
  assert_character(x, name)
}


assert_file_exists <- function(path, name = deparse(substitute(path))) {
  assert_scalar_character(path, name)
  if (!file.exists(path)) {
    stop(sprintf("The path '%s' does not exist (for '%s')", path, name),
         call. = FALSE)
  }
  invisible(path)
}


match_value <- function(arg, choices, name = deparse(substitute(arg))) {
  assert_scalar_character(arg)
  if (!(arg %in% choices)) {
    stop(sprintf("%s must be one of %s",
                 name, paste(squote(choices), collapse = ", ")))
  }
  arg
}


assert_named <- function(x, unique = FALSE, name = deparse(substitute(x)),
                         what = "named") {
  nms <- names(x)
  if (is.null(nms)) {
    stop(sprintf("'%s' must be %s", name, what), call. = FALSE)
  }
  if (!all(nzchar(nms))) {
    stop(sprintf("All elements of '%s' must be named", name), call. = FALSE)
  }
  if (unique && any(duplicated(nms))) {
    stop(sprintf("'%s' must have unique names", name), call. = FALSE)
  }
}
