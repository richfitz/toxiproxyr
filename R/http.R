toxiproxy_request <- function(action, verb, url, path, ..., body = NULL) {
  res <- verb(paste0(url, prepare_path(path)), httr::accept_json(),
              body = body, encode = "json", ...)
  toxiproxy_client_response(res, action)
}


toxiproxy_client_response <- function(res, action) {
  code <- httr::status_code(res)
  force(action)

  if (code >= 300) {
    if (response_is_json(res, TRUE)) {
      msg <- response_to_json(res)$error %||% "Unknown error"
    } else {
      msg <- paste("http error", response_to_text(res))
    }
    stop(toxiproxy_error(code, msg, action))
  }

  if (length(res$content) == 0) {
    ret <- invisible(NULL)
  } else if (response_is_json(res, FALSE)) {
    ret <- response_to_json(res)
  } else {
    ## NOTE: assuming text
    ret <- response_to_text(res)
  }

  ret
}


toxiproxy_error <- function(code, msg, action) {
  message <- sprintf("While %s, toxiproxy errored because %s", action, msg)
  err <- list(code = code, msg = msg, action = action, message = message)
  class(err) <- c("toxiproxy_error", "error", "condition")
  err
}


prepare_path <- function(path, name = deparse(substitute(path))) {
  assert_scalar_character(path, name = name)
  if (!is_absolute_path(path)) {
    path <- paste0("/", path)
  }
  path
}


## For errors, there's an issue because toxiproxy reports
##
##   Content-Type: text/plain; charset=utf-8
##
## but it actually contains json.  So we'll have to sniff it and
## that's not ideal.
##
## Previously I wrote:
##
##   > toxiproxy's response type header is broken, so we have to sniff
##   > content to get the correct content.  This is an issue because
##   > it *is* possible to throw an error that returns genuine
##   > text/plain (e.g. access a non-existant endpoint) and then the
##   > JSON parsing fails!
response_is_json <- function(x, loose) {
  content_type <- httr::headers(x)[["Content-Type"]]
  dat <- httr::parse_media(content_type)
  raw <- httr::content(x, "raw")
  (dat$type == "application" && dat$subtype == "json") ||
    (loose && length(raw) > 0 && raw[[1L]] == 0x7b)
}


response_to_json <- function(res) {
  jsonlite::fromJSON(httr::content(res, "text", encoding = "UTF-8"),
                     simplifyVector = FALSE)
}


response_to_text <- function(res) {
  trimws(httr::content(res, "text", encoding = "UTF-8"))
}
