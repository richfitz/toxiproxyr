context("server manager")

test_that("safeguards for run", {
  skip_on_cran()

  withr::with_envvar(c(NOT_CRAN = NA_character_), {
    expect_null(toxiproxy_server_manager_bin())
  })

  withr::with_envvar(c(TOXIPROXYR_SERVER_BIN_PATH = NA_character_), {
    expect_null(toxiproxy_server_manager_bin())
  })

  withr::with_envvar(c(TOXIPROXYR_SERVER_BIN_PATH = tempfile()), {
    expect_null(toxiproxy_server_manager_bin())
  })

  path <- tempfile()
  file.create(path)
  withr::with_envvar(c(TOXIPROXYR_SERVER_BIN_PATH = path), {
    expect_null(toxiproxy_server_manager_bin())
  })

  path <- tempfile()
  dir.create(path)
  withr::with_envvar(c(TOXIPROXYR_SERVER_BIN_PATH = path), {
    expect_null(toxiproxy_server_manager_bin())
  })

  toxiproxy <- file.path(path, "toxiproxy")
  file.create(toxiproxy)
  withr::with_envvar(c(TOXIPROXYR_SERVER_BIN_PATH = path), {
    expect_equal(normalizePath(toxiproxy_server_manager_bin()),
                 normalizePath(toxiproxy))
  })

  withr::with_envvar(c(TOXIPROXYR_SERVER_PORT = NA_character_), {
    expect_equal(toxiproxy_server_manager_port(), 18474L)
  })
  withr::with_envvar(c(TOXIPROXYR_SERVER_PORT = "1000"), {
    expect_equal(toxiproxy_server_manager_port(), 1000)
  })
  withr::with_envvar(c(TOXIPROXYR_SERVER_PORT = "port"), {
    expect_error(toxiproxy_server_manager_port(), "Invalid port 'port'")
  })
})


test_that("disabled server manager", {
  res <- R6_toxiproxy_server_manager$new(NULL)
  expect_false(res$enabled)
  expect_equal(res$new_server(if_disabled = identity),
               "toxiproxy is not enabled")
  expect_error(res$new_server(if_disabled = stop),
               "toxiproxy is not enabled")
})


test_that("timeout catch", {
  client <- list(server_version = function() stop("error"))
  path <- tempfile()
  txt <- c("information about the process",
           "on two lines")
  writeLines(txt, path)
  
  process <- list(is_alive = function() FALSE,
                  get_error_file = function() path)
  expect_error(toxiproxy_server_wait(client, process),
               paste(c("toxiproxy has died:", txt), collapse = "\n"),
               fixed = TRUE)
})


test_that("timeout poll", {
  n <- 0L
  client <- list(server_version = function() {
    if (n >= 5) {
      return(numeric_version("1.0.0"))
    } else {
      n <<- n + 1
    }
  })

  process <- list(is_alive = function() TRUE)
  msgs <- testthat::capture_messages(
    toxiproxy_server_wait(client, process, poll = 0))
  expect_equal(trimws(msgs), rep("...waiting for toxiproxy to start", 5))
})


test_that("version", {
  srv <- toxiproxy_server()
  expect_is(srv$version(), "numeric_version")
})


test_that("populate on startup", {
  ## Need something to proxy!
  srv1 <- toxiproxy_server()

  dat <- list(list(name = "self",
                   listen = "127.0.0.1:22222",
                   upstream = sprintf("127.0.0.1:%d", srv1$port)))
  config <- tempfile()
  jsonlite::write_json(dat, config, auto_unbox = TRUE, pretty = TRUE)

  srv2 <- toxiproxy_server(config)
  expect_equal(
    srv2$client()$list(),
    data_frame(name = "self", listen = "127.0.0.1:22222",
               upstream = dat[[1]]$upstream,
               enabled = TRUE, toxics = 0L))
})
