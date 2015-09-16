##' Create a connection to the toxiproxy server.
##'
##' The main entry point to the package.
##' @title Create a connection to the toxiproxy server
##' @param host Hostname to use; default assumes toxiproxy running locally
##' @param port Port to use; default assumes toxiproxy defaults
##' @export
toxiproxy <- function(host="127.0.0.1", port=8474) {
  .R6_toxiproxy$new(host, port)
}

##' @importFrom R6 R6Class
##' @importFrom httr GET
.R6_toxiproxy <-
  R6::R6Class(
    "toxiproxy",
    public=
      list(
        host=NULL,
        port=NULL,
        url_prefix=NULL,

        initialize=function(host, port) {
          self$host <- host
          self$port <- port
          self$url_prefix <- sprintf("http://%s:%s", host, port)
          if (!is_socket_open(host, port)) {
            stop("toxiproxy does not appear to be running at ", self$url_prefix)
          }
        },

        url=function(...) {
          paste0(self$url_prefix, sprintf(...))
        },

        reset=function() {
          response <- httr::GET(self$url("/reset"))
          assert_response(response)
          invisible(self)
        },

        all=function() {
          response <- httr::GET(self$url("/proxies"))
          assert_response(response)
          lapply(httr::content(response), toxiproxy_proxy, self)
        },

        create=function(name, upstream, listen=0, enabled=TRUE) {
          if (is.numeric(upstream)) {
            upstream <- sprintf("%s:%d", self$host, upstream)
          }
          if (is.numeric(listen)) {
            listen <- sprintf("%s:%d", self$host, listen)
          }
          hash <- list(name=name, listen=listen,
                       upstream=upstream, enabled=enabled)
          response <- httr::POST(self$url("/proxies"), body=to_json(hash))
          assert_response(response)

          toxiproxy_proxy(httr::content(response), self)
        },

        ## Helper functions:
        list=function() {
          response <- httr::GET(self$url("/proxies"))
          assert_response(response)
          names(httr::content(response))
        },

        get=function(name) {
          dat <- self$all()
          if (!(name %in% names(dat))) {
            stop(sprintf("'%s' not known to toxiproxy", name))
          }
          dat[[name]]
        },

        delete=function(name) {
          response <- httr::DELETE(self$url("/proxies/%s", name))
          assert_response(response)
          invisible(self)
        },

        ## Untested, but would be similar to the Ruby interface.
        populate=function(data) {
          data <- lapply(data, modifyList, list(listen=0, enabled=TRUE))
          lapply(data, function(x)
            self$create(x$name, x$upstream, x$listen, x$enabled))
          invisible(self)
        }
      ))
