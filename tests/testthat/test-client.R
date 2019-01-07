context("client")

test_that("version", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  expect_is(cl$server_version(), "numeric_version")
})


test_that("api", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  expect_is(cl$api(), "toxiproxy_api_client")
})


test_that("create proxy", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port)
  expect_is(p, "toxiproxy_proxy")
  expect_equal(
    cl$list(),
    data_frame(
      name = "self",
      listen = p$listen,
      upstream = p$upstream,
      enabled = TRUE,
      toxics = 0L))
})


test_that("get proxy", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p1 <- cl$create("self", srv$port)
  p2 <- cl$get("self")
  expect_equal(p1, p2)
})


test_that("delete proxy", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  cl$create("self", srv$port)
  d <- cl$list()
  expect_null(cl$delete("self"))
  expect_equal(cl$list(), d[integer(0), ])
})


test_that("reset proxies", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port, enabled = FALSE)
  expect_false(p$enabled)

  ## TODO: should add a toxic here.

  cl$reset()
  expect_true(p$enabled)
})


test_that("check_address substitutes numbers", {
  expect_equal(check_address(10000), "localhost:10000")
  expect_equal(check_address(10000, "other"), "other:10000")
  expect_equal(check_address(10000, "127.0.0.1"), "127.0.0.1:10000")
})


test_that("check_address validates strings", {
  expect_equal(check_address("localhost:10000"), "localhost:10000")
  expect_equal(check_address("127.0.0.1:10000"), "127.0.0.1:10000")
  expect_error(check_address("http://localhost:10000", name = "address"),
               "'address' must be in the form '<host>:<port>'",
               fixed = TRUE)
  expect_error(check_address("localhost:10000/bar", name = "address"),
               "'address' must be in the form '<host>:<port>'",
               fixed = TRUE)
  expect_error(check_address("localhost", name = "address"),
               "'address' must be in the form '<host>:<port>'",
               fixed = TRUE)
})
