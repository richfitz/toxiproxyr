## Internally used function; not for users to call.
toxiproxy_proxy <- function(data, tox) {
  ## TODO: add populate() method and argument to allow bulk creation
  ## here.
  .R6_toxiproxy_proxy$new(data, tox)
}

.R6_toxiproxy_proxy <-
  R6::R6Class(
    "toxiproxy_proxy",
    public=
      list(
        tox=NULL,
        name=NULL,
        listen=NULL,
        upstream=NULL,
        listen_host=NULL,
        listen_port=NULL,
        url_prefix=NULL,

        initialize=function(data, tox) {
          self$tox <- tox
          self$name <- data$name
          self$listen <- data$listen
          tmp <- strsplit(self$listen, ":")[[1]]
          self$listen_host <- tmp[[1]]
          self$listen_port <- tmp[[2]]
          self$url_prefix <- self$tox$url("/proxies/%s", self$name)
          self$upstream <- data$upstream
        },

        url=function(...) {
          file.path(self$url_prefix, sprintf(...))
        },

        destroy=function() {
          response <- httr::DELETE(self$url())
          assert_response(response)
          ## TODO: Some sort of self-destruction would seem worthwhile here.
        },

        ## Control over the *global state* of this proxy:
        update_state=function(state) {
          assert_scalar_logical(state)
          response <- httr::POST(self$url(), body=to_json(list(enabled=state)))
          assert_response(response)
          invisible(self)
        },
        disable=function() {
          self$update_state(FALSE)
        },
        enable=function() {
          self$update_state(TRUE)
        },

        is_enabled=function() {
          response <- httr::GET(self$url())
          assert_response(response)
          httr::content(response)$enabled
        },

        down=function(expr) {
          if (self$is_enabled()) {
            self$disable()
            on.exit(self$enable())
          }
          force(expr)
        },

        ## Control over toxics applied to this proxy:
        with=function(set, expr) {
          self$enable_toxics(set)
          on.exit(self$disable_toxics(set))
          force(expr)
        },
        enable_toxics=function(set) {
          vlapply(set, self$update_toxic, TRUE)
        },
        disable_toxics=function(set) {
          vlapply(set, self$update_toxic, FALSE)
        },

        update_toxic=function(tox, enabled=NULL, direction=tox$direction) {
          assert_inherits(tox, "toxic")
          assert_direction(direction)
          data <- tox$data
          if (!is.null(enabled)) {
            data$enabled <- enabled
          }
          url <- self$url("%s/toxics/%s", direction, tox$name)
          response <- httr::POST(url, body=to_json(data))
          assert_response(response)
          httr::content(response)$enabled
        },

        ## Then, get the current set of toxics:
        toxics=function(all=FALSE) {
          f <- function(direction) {
            response <- httr::GET(self$url("%s/toxics", direction))
            assert_response(response)
            dat <- httr::content(response)
            if (!all) {
              dat <- dat[vlapply(dat, "[[", "enabled")]
            }
            lnapply(dat, toxic)
          }
          toxic_set(upstream=f("upstream"),
                    downstream=f("downstream"))
        }
      ))
