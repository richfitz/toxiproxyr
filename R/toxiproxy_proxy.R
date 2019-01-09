##' Toxic proxies are created by the \code{$create} method of the
##' \code{\link{toxiproxy_client}} and returned by the \code{$get}
##' method.  They are R6 methods with methods and fields, which are
##'
##' @template toxiproxy_proxy
##'
##' @title Toxiproxy proxy
##' @name toxiproxy_proxy
NULL

toxiproxy_proxy <- R6::R6Class(
  "toxiproxy_proxy",
  cloneable = FALSE,
  private = list(
    api_client = NULL,
    path = NULL,
    path_toxics = NULL
  ),

  public = list(
    name = NULL,

    initialize = function(api_client, dat) {
      private$api_client <- api_client
      private$path <- paste0("/proxies/", dat$name)
      private$path_toxics <- sprintf("/proxies/%s/toxics", dat$name)

      self$name <- dat$name
      lockBinding("name", self)
    },

    describe = function() {
      private$api_client$GET(
        sprintf("fetching proxy '%s'", self$name), private$path)
    },

    add = function(type, stream = "downstream", toxicity = 1,
                   attributes = list(), name = NULL) {
      if (inherits(type, "toxic")) {
        if (length(attributes) > 0L) {
          stop("'attributes' must be empty when using a toxic object")
        }
        attributes <- type$attributes
        type <- type$type
      }

      assert_scalar_numeric(toxicity)
      if (toxicity < 0 || toxicity > 1) {
        stop("'toxicity' must lie in the range [0, 1]", call. = FALSE)
      }
      if (!is.null(name)) {
        assert_scalar_character(name)
      }
      body <- list(type = assert_scalar_character(type),
                   stream = match_value(stream, c("downstream", "upstream")),
                   toxicity = toxicity,
                   attributes = toxic_attributes(attributes),
                   name = name)
      res <- private$api_client$POST(
        "adding a toxic", private$path_toxics, body = body)
      res$name
    },

    list = function() {
      res <- private$api_client$GET(
        sprintf("listing toxics for proxy '%s'", self$name),
        private$path_toxics)
      data_frame(
        name = vcapply(res, "[[", "name"),
        type = vcapply(res, "[[", "type"),
        stream = vcapply(res, "[[", "stream"),
        toxicity = vnapply(res, "[[", "toxicity"),
        attributes = I(lapply(res, "[[", "attributes")))
    },

    remove = function(name) {
      assert_scalar_character(name)
      path <- sprintf("%s/%s", private$path_toxics, name)
      private$api_client$DELETE(
        sprintf("removing toxic '%s' from proxy '%s'", name, self$name), path)
    },

    info = function(name) {
      assert_scalar_character(name)
      path <- sprintf("%s/%s", private$path_toxics, name)
      res <- private$api_client$GET(
        sprintf("fetching toxic '%s' from proxy '%s'", name, self$name), path)
      res[c("name", "type", "stream", "toxicity", "attributes")]
    },

    update_toxic = function(name, attributes) {
      assert_scalar_character(name)
      path <- sprintf("%s/%s", private$path_toxics, name)
      body <- list(attributes = toxic_attributes(attributes))
      private$api_client$POST(
        sprintf("updating toxic '%s' for proxy '%s'", name, self$name),
        path, body = body)
      invisible(NULL)
    },

    update_proxy = function(upstream = NULL, listen = NULL, enabled = NULL) {
      body <- drop_null(list(
        listen = listen %&&%
          check_address(listen %||% 0, private$api_client$host),
        upstream = upstream %&&% check_address(upstream),
        enabled = enabled %&&% assert_scalar_logical(enabled)))
      private$api_client$POST(
        sprintf("updating proxy '%s'", self$name), private$path, body = body)
      invisible(self)
    },

    with_down = function(expr) {
      if (self$enabled) {
        self$update_proxy(enabled = FALSE)
        on.exit(self$update_proxy(enabled = TRUE))
      }
      force(expr)
    }
  ),

  active = list(
    listen = function(value) {
      if (missing(value)) {
        self$describe()$listen
      } else {
        self$update_proxy(listen = value)
      }
    },

    listen_port = function(value) {
      if (missing(value)) {
        as.integer(sub("^.+:", "", self$describe()$listen))
      } else {
        self$update_proxy(
          listen = sub("[0-9]+$", as.character(value), self$listen))
      }
    },

    upstream = function(value) {
      if (missing(value)) {
        self$describe()$upstream
      } else {
        self$update_proxy(upstream = value)
      }
    },

    enabled = function(value) {
      if (missing(value)) {
        self$describe()$enabled
      } else {
        self$update_proxy(enabled = value)
      }
    }
  ))


toxic_attributes <- function(x, name = deparse(substitute(x))) {
  assert_named(x, unique = TRUE, name = name)
  for (i in names(x)) {
    assert_scalar(x[[i]], name = sprintf("%s$%s", name, i))
  }
  x
}
