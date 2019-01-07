context("util")

test_that("Sys_getenv", {
  expect_null(Sys_getenv("TOXIPROXYR_NONEXISTANT"))

  withr::with_envvar(c("TOXIPROXYR_NONEXISTANT" = 123), {
    expect_equal(Sys_getenv("TOXIPROXYR_NONEXISTANT"), "123")
    expect_equal(Sys_getenv("TOXIPROXYR_NONEXISTANT", mode = "integer"), 123L)
  })

  withr::with_envvar(c("TOXIPROXYR_NONEXISTANT" = "foo"), {
    expect_equal(Sys_getenv("TOXIPROXYR_NONEXISTANT"), "foo")
    expect_error(Sys_getenv("TOXIPROXYR_NONEXISTANT", mode = "integer"),
                 "Invalid input for integer 'foo'")
    expect_error(Sys_getenv("TOXIPROXYR_NONEXISTANT", mode = "other"),
                 "Invalid value for 'mode'")
  })
})


test_that("free_port: failure", {
  skip_on_cran()
  skip_if_not_installed("mockery")
  mockery::stub(free_port, "check_port", FALSE)
  expect_error(free_port(10000, 0),
               "Did not find a free port between 10000..9999")
  expect_error(free_port(10000, 10),
               "Did not find a free port between 10000..10009")
})


test_that("free_port: used", {
  srv <- toxiproxy_server()
  expect_false(check_port(srv$port))
})


test_that("download_file", {
  srv <- toxiproxy_server()
  url <- sprintf("%s/version", srv$addr)
  path <- download_file(url, quiet = TRUE)
  expect_true(file.exists(path))
  expect_equal(readLines(path, warn = FALSE), as.character(srv$version()))
})
