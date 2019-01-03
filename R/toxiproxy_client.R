##' Make a toxiproxyy client.  This must be done before accessing the
##' toxiproxy server.  The default for arguments are controlled by
##' environment variables (see Details) and values provided as
##' arguments override these defaults.
##'
##' @title Make a toxiproxy client
##'
##' @param addr The value address \emph{including protocol and port},
##'   e.g., \code{http://toxiproxy.example.com:8474}.  If not given, the
##'   default is the environment variable \code{TOXIPROXY_ADDR}.
##'
##' @export
##' @author Rich FitzJohn
toxiproxy_client <- function(addr = NULL) {
  R6_toxiproxy_client$new(addr)
}


R6_toxiproxy_client <- R6::R6Class(
  "toxiproxy_client",

  cloneable = FALSE,

  private = list(
    api_client = NULL),

  public = list(
    initialize = function(addr) {
      private$api_client <- toxiproxy_api_client$new(addr)
    },

    api = function() {
      private$api_client
    },

    server_version = function(refresh = FALSE) {
      private$api_client$server_version(refresh)
    }
  ))
