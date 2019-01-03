##' Control a server for use with testing.  This is designed to be
##' used only by other packages that wish to run tests against a
##' toxiproxy server.  You will need to set
##' \code{TOXIPROXYR_SERVER_BIN_PATH} to point at the directory
##' containing the toxiproxy binary.
##'
##' The function \code{toxiproxy_server_install} will install a
##' server, but \emph{only} if the user opts in by setting the
##' environment variable \code{TOXIPROXYR_SERVER_INSTALL} to
##' \code{"true"}, and by setting \code{TOXIPROXYR_SERVER_BIN_PATH} to
##' the directory where the binary should be downloaded to.  This will
##' download a ~10MB binary from
##' \url{https://github.com/Shopify/toxiproxy/releases} so use with
##' care.  It is intended \emph{only} for use in automated testing
##' environments.
##'
##' @title Control a test vault server
##'
##' @param config Not yet handled
##'
##' @param seed Not yet handled
##'
##' @param if_disabled Callback function to run if the vault server is
##'   not enabled.  The default, designed to be used within tests, is
##'   \code{testthat::skip}.  Alternatively, inspect the
##'   \code{$enabled} property of the returned object.
##'
##' @export
##' @rdname toxiproxy_server
toxiproxy_server <- function(config = NULL, seed = NULL,
                             if_disabled = testthat::skip) {
  toxiproxy_server_manager()$new_server(config, seed, if_disabled)
}


toxiproxy_server_manager <- function() {
  if (is.null(toxiproxy_env$server_manager)) {
    bin <- toxiproxy_server_manager_bin()
    port <- toxiproxy_server_manager_port()
    toxiproxy_env$server_manager <- R6_toxiproxy_server_manager$new(bin, port)
  }
  toxiproxy_env$server_manager
}


toxiproxy_server_manager_bin <- function() {
  if (!identical(Sys.getenv("NOT_CRAN"), "true")) {
    return(NULL)
  }
  path <- Sys_getenv("TOXIPROXYR_SERVER_BIN_PATH", NULL)
  if (is.null(path)) {
    return(NULL)
  }
  if (!file.exists(path) || !is_directory(path)) {
    return(NULL)
  }
  bin <- file.path(path, "toxiproxy")
  if (!file.exists(bin)) {
    return(NULL)
  }
  normalizePath(bin, mustWork = TRUE)
}


toxiproxy_server_manager_port <- function() {
  port <- Sys.getenv("TOXIPROXYR_SERVER_PORT", NA_character_)
  if (is.na(port)) {
    return(18474L)
  }
  if (!grepl("^[0-9]+$", port)) {
    stop(sprintf("Invalid port '%s'", port))
  }
  as.integer(port)
}


R6_toxiproxy_server_manager <- R6::R6Class(
  "toxiproxy_server_manager",

  public = list(
    bin = NULL,
    port = NULL,
    enabled = FALSE,

    initialize = function(bin, port) {
      if (is.null(bin)) {
        self$enabled <- FALSE
      } else {
        assert_scalar_character(bin)
        assert_scalar_integer(port)
        self$bin <- normalizePath(bin, mustWork = TRUE)
        self$port <- port
        self$enabled <- TRUE
      }
    },

    new_port = function() {
      gc() # try and free up any previous cases
      ret <- free_port(self$port)
      self$port <- self$port + 1L
      ret
    },

    new_server = function(config = NULL, seed = NULL,
                          if_disabled = testthat::skip) {
      if (!self$enabled) {
        if_disabled("toxiproxy is not enabled")
      } else {
        tryCatch(
          toxiproxy_server_instance$new(self$bin, self$new_port(),
                                        config, seed),
          error = function(e)
            testthat::skip(paste("toxiproxy server failed to start:",
                                 e$message)))
      }
    }
  ))


toxiproxy_server_instance <- R6::R6Class(
  "toxiproxy_server_instance",

  public = list(
    port = NULL,

    process = NULL,
    addr = NULL,

    initialize = function(bin, port, config, seed) {
      assert_scalar_integer(port)
      self$port <- port

      bin <- normalizePath(bin, mustWork = TRUE)
      dat <- toxiproxy_server_start(bin, self$port, config, seed)

      for (i in names(dat)) {
        self[[i]] <- dat[[i]]
      }
    },

    version = function() {
      self$client()$server_version()
    },

    client = function() {
      toxiproxy_client(addr = self$addr)
    },

    finalize = function() {
      self$kill()
    },

    kill = function() {
      if (!is.null(self$process)) {
        self$process$kill()
        self$process <- NULL
      }
    }
  ))


toxiproxy_server_wait <- function(cl, process, timeout = 5, poll = 0.05) {
  t1 <- Sys.time() + timeout
  repeat {
    ok <- tryCatch(inherits(cl$server_version(), "numeric_version"),
                   error = function(e) FALSE)
    if (ok) {
      break
    }
    if (!process$is_alive() || Sys.time() > t1) {
      err <- paste(readLines(process$get_error_file()), collapse = "\n")
      stop("toxiproxy has died:\n", err)
    }
    message("...waiting for toxiproxy to start")
    Sys.sleep(poll)
  }
}


toxiproxy_server_start <- function(bin, port, config, seed) {
  args <- c("-host", "localhost",
            "-port", port,
            if (!is.null(config)) c("-config", config),
            if (!is.null(seed)) c("-seed", seed))
  stdout <- tempfile()
  stderr <- tempfile()
  process <-
    processx::process$new(bin, args, stdout = stdout, stderr = stderr)
  on.exit(process$kill())

  addr <- sprintf("http://127.0.0.1:%d", port)
  toxiproxy_server_wait(toxiproxy_api_client$new(addr), process)
  on.exit()

  list(process = process,
       addr = addr)
}
