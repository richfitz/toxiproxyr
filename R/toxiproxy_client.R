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
##' @template toxiproxy_client
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
    },

    list = function() {
      dat <- private$api_client$GET(
        "getting the list of proxies", "/proxies")
      ret <- data_frame(
        name = vcapply(dat, "[[", "name"),
        listen = vcapply(dat, "[[", "listen"),
        upstream = vcapply(dat, "[[", "upstream"),
        enabled = vlapply(dat, "[[", "enabled"),
        toxics = viapply(dat, function(x) length(x$toxics)))
      rownames(ret) <- NULL
      ret
    },

    create = function(name, upstream, listen = NULL, enabled = TRUE) {
      body <- list(
        name = assert_scalar_character(name),
        listen = check_address(listen %||% 0, private$api_client$host),
        upstream = check_address(upstream),
        enabled = assert_scalar_logical(enabled))
      dat <- private$api_client$POST(
        sprintf("creating proxy '%s'", name), "/proxies", body = body)
      toxiproxy_proxy$new(private$api_client, dat)
    },

    reset = function() {
      private$api_client$POST("resetting toxiproxy", "/reset")
      invisible(self)
    },

    get = function(name) {
      path <- paste0("/proxies/", assert_scalar_character(name))
      dat <- private$api_client$GET(
        sprintf("fetching proxy '%s'", name), path)
      toxiproxy_proxy$new(private$api_client, dat)
    },

    remove = function(name) {
      path <- paste0("/proxies/", assert_scalar_character(name))
      private$api_client$DELETE(
        sprintf("removing proxy '%s'", name), path)
      invisible(self)
    },

    populate = function(data) {
      body <- check_populate_data(data, private$api_client$host)
      private$api_client$POST(
        "populating proxies", "/populate", body = body)
      invisible(self)
    }
  ))


check_address <- function(x, default_host = "localhost",
                          name = deparse(substitute(x))) {
  if (is.numeric(x)) {
    assert_scalar_integer(x, name = name)
    x <- sprintf("%s:%s", default_host, x)
  } else {
    assert_scalar_character(x, name = name)
    if (grepl("^[0-9]+$", x)) {
      x <- sprintf("%s:%s", default_host, x)
    } else if (!grepl("^[^:]+:[0-9]+$", x)) {
      stop(sprintf("'%s' must be in the form '<host>:<port>'", name),
           call. = FALSE)
    }
  }
  x
}


check_populate_data <- function(data, server_host) {
  assert_is(data, "data.frame")
  assert_named(data)
  required <- c("name", "listen", "upstream")
  msg <- setdiff(required, names(data))
  if (length(msg) > 0L) {
    stop(sprintf("Missing required %s in 'data': %s",
                 ngettext(length(msg), "field", "fields"),
                 paste(squote(msg), collapse = ", ")),
         call. = FALSE)
  }
  assert_character(data$name)
  data$listen <- vcapply(
    data$listen, check_address, server_host, "data$listen")
  data$upstream <- vcapply(
    data$upstream, check_address, name = "data$upstream")
  data[required]
}
