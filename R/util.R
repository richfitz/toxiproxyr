Sys_getenv <- function(name, unset = NULL, mode = "character") {
  value <- Sys.getenv(name, NA_character_)
  if (is.na(value)) {
    value <- unset
  } else if (mode == "integer") {
    if (!grepl("^-?[0-9]+$", value)) {
      stop(sprintf("Invalid input for integer '%s'", value))
    }
    value <- as.integer(value)
  } else if (mode != "character") {
    stop("Invalid value for 'mode'")
  }
  value
}


download_file <- function(url, path = tempfile(), quiet = FALSE) {
  r <- httr::GET(url, httr::write_disk(path), if (!quiet) httr::progress())
  httr::stop_for_status(r)
  path
}


is_directory <- function(path) {
  file.info(path, extra_cols = FALSE)$isdir
}


free_port <- function(port, max_tries = 20) {
  for (i in seq_len(max_tries)) {
    if (check_port(port)) {
      return(port)
    }
    port <- port + 1L
  }
  stop(sprintf("Did not find a free port between %d..%d",
               port - max_tries, port - 1),
       call. = FALSE)
}


check_port <- function(port) {
  con <- tryCatch(suppressWarnings(socketConnection(
    "localhost", port = port, timeout = 0.1, open = "r")),
    error = function(e) NULL)
  if (is.null(con)) {
    return(TRUE)
  }
  close(con)
  FALSE
}


`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}


is_absolute_path <- function(path) {
  substr(path, 1, 1) == "/"
}


squote <- function(x) {
  sprintf("'%s'", x)
}
