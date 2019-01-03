context("server install")

test_that("safeguards for install", {
  skip_on_cran()

  withr::with_envvar(c(NOT_CRAN = NA_character_), {
    expect_error(toxiproxy_server_install(),
                 "Do not run this on CRAN")
  })

  withr::with_envvar(c(TOXIPROXYR_SERVER_INSTALL = NA_character_), {
    expect_error(toxiproxy_server_install(),
                 "Please read the documentation for toxiproxy_server_install")
  })

  withr::with_envvar(c(TOXIPROXYR_SERVER_INSTALL = "true",
                       TOXIPROXYR_SERVER_BIN_PATH = NA_character_), {
    expect_error(toxiproxy_server_install(),
                 "TOXIPROXYR_SERVER_BIN_PATH is not set")
  })
})


test_that("install", {
  testthat::skip_on_cran()
  skip_if_no_internet()

  path <- tempfile()
  vars <- c(TOXIPROXYR_SERVER_BIN_PATH = path,
            TOXIPROXYR_SERVER_INSTALL = "true")

  res <- withr::with_envvar(vars, {
    toxiproxy_server_install(TRUE)
  })

  expect_equal(res, file.path(path, "toxiproxy"))
  expect_true(file.exists(res))
  expect_equal(dir(path), "toxiproxy")
})


test_that("reinstall", {
  testthat::skip_on_cran()
  skip_if_no_internet()

  path <- tempfile()
  vars <- c(TOXIPROXYR_SERVER_BIN_PATH = path,
            TOXIPROXYR_SERVER_INSTALL = "true")

  dir.create(path)
  dest <- file.path(path, "toxiproxy")
  writeLines("toxiproxy", dest)
  res <- withr::with_envvar(vars, {
    expect_message(toxiproxy_server_install(path, TRUE),
                   "toxiproxy already installed at")
  })
  expect_identical(readLines(dest), "toxiproxy")
})


test_that("toxiproxy_platform", {
  expect_equal(toxiproxy_platform("Darwin"), "darwin")
  expect_equal(toxiproxy_platform("Windows"), "windows")
  expect_equal(toxiproxy_platform("Linux"), "linux")
  expect_error(toxiproxy_platform("Solaris"), "Unknown sysname")
})
