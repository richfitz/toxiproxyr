toxiproxy_request <- function(verb, url, path, ..., body = NULL) {
  res <- verb(paste0(url, prepare_path(path)), httr::accept_json(),
              body = body, encode = "json", ...)
  toxiproxy_client_response(res)
}


toxiproxy_client_response <- function(res) {
  code <- httr::status_code(res)

  if (code >= 400 && code < 600) {
    if (response_is_json(res)) {
      stop("handle error properly")
      ## dat <- response_to_json(res)
      ## errors <- list_to_character(dat$errors)
      ## warnings <- list_to_character(dat$warnings)
      ## text <- paste(c(errors, warnings), collapse = "\n")
    } else {
      errors <- NULL
      text <- trimws(httr::content(res, "text", encoding = "UTF-8"))
    }
    stop(toxiproxy_error(code, text, errors))
  }

  if (length(res$content) == 0) {
    ret <- invisible(NULL)
  } else if (response_is_json(res)) {
    ret <- response_to_json(res)
  } else {
    ## NOTE: assuming text
    ret <- response_to_text(res)
  }

  ret
}


toxiproxy_error <- function(code, text, errors) {
  if (!nzchar(text)) {
    text <- httr::http_status(code)$message
  }
  type <- switch(as.character(code),
                 "400" = "toxiproxy_invalid_request",
                 "401" = "toxiproxy_unauthorized",
                 "403" = "toxiproxy_forbidden",
                 "404" = "toxiproxy_invalid_path",
                 "429" = "toxiproxy_rate_limit_exceeded",
                 "500" = "toxiproxy_internal_server_error",
                 "501" = "toxiproxy_not_initialized",
                 "503" = "toxiproxy_down",
                 "toxiproxy_unknown_error")
  err <- list(code = code,
              errors = errors,
              message = text)
  class(err) <- c(type, "toxiproxy_error", "error", "condition")
  err
}


prepare_path <- function(path, name = deparse(substitute(path))) {
  assert_scalar_character(path, name = name)
  if (!is_absolute_path(path)) {
    path <- paste0("/", path)
  }
  path
}


response_is_json <- function(x) {
  content_type <- httr::headers(x)[["Content-Type"]]
  dat <- httr::parse_media(content_type)
  dat$type == "application" && dat$subtype == "json"
}


response_to_json <- function(res) {
  jsonlite::fromJSON(httr::content(res, "text", encoding = "UTF-8"),
                     simplifyVector = FALSE)
}


response_to_text <- function(res) {
  httr::content(res, "text", encoding = "UTF-8")
}
