toxiproxy_api_client <- R6::R6Class(
  "toxiproxy_api_client",

  public = list(
    addr = NULL,
    version = NULL,

    initialize = function(addr = NULL) {
      self$addr <- toxiproxy_addr(addr)
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
  if (!grepl("^http://.+", addr)) {
    stop("Expected an http url for toxiproxy addr")
  }
  ## TODO: assume no trailing slash?
  addr
}
