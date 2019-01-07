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
      private$api_client$GET(private$path)
    },

    add = function(type, stream = "downstream", toxicity = 1,
                   attributes = list(), name = NULL) {
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
      res <- private$api_client$POST(private$path_toxics, body = body)
      res$name
    },

    list = function() {
      res <- private$api_client$GET(private$path_toxics)
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
      private$api_client$DELETE(path)
    },

    info = function(name) {
      assert_scalar_character(name)
      path <- sprintf("%s/%s", private$path_toxics, name)
      res <- private$api_client$GET(path)
      res[c("name", "type", "stream", "toxicity", "attributes")]
    },

    update_toxic = function(name, attributes) {
      assert_scalar_character(name)
      path <- sprintf("%s/%s", private$path_toxics, name)
      body <- list(attributes = toxic_attributes(attributes))
      private$api_client$POST(path, body = body)
      invisible(NULL)
    },

    update_proxy = function(upstream = NULL, listen = NULL, enabled = NULL) {
      body <- drop_null(list(
        listen = listen %&&%
          check_address(listen %||% 0, private$api_client$host),
        upstream = upstream %&&% check_address(upstream),
        enabled = enabled %&&% assert_scalar_logical(enabled)))
      private$api_client$POST(private$path, body = body)
      invisible(self)
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
