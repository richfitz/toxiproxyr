toxiproxy_api_client <- R6::R6Class(
  "toxiproxy_api_client",

  public = list(
    addr = NULL,
    host = NULL,
    port = NULL,
    version = NULL,

    initialize = function(addr = NULL) {
      dat <- toxiproxy_addr(addr)
      self$addr <- dat$addr
      self$host <- dat$host
      self$port <- dat$port
    },

    request = function(verb, path, ...) {
      toxiproxy_request(verb, self$addr, path, ...)
    },

    server_version = function(refresh = FALSE) {
      if (is.null(self$version) || refresh) {
        self$version <- numeric_version(self$GET("/version"))
      }
      self$version
    },

    GET = function(path, ...) {
      self$request(httr::GET, path, ...)
    },

    POST = function(path, ...) {
      self$request(httr::POST, path, ...)
    },

    DELETE = function(path, ...) {
      self$request(httr::DELETE, path, ...)
    }
  ))


toxiproxy_addr <- function(addr) {
  addr <- addr %||% Sys.getenv("TOXIPROXY_ADDR", "")
  assert_scalar_character(addr)
  if (!nzchar(addr)) {
    stop("toxiproxy address not found: perhaps set 'TOXIPROXY_ADDR'",
         call. = FALSE)
  }

  re <- "^http://(.+):([0-9]+)$"
  if (!grepl(re, addr)) {
    stop("Expected an http url for toxiproxy addr in the form http://host:port")
  }

  list(addr = addr,
       host = sub(re, "\\1", addr),
       port = as.integer(sub(re, "\\2", addr)))
}
