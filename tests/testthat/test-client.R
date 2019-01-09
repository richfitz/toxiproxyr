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


test_that("remove proxy", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  cl$create("self", srv$port)
  d <- cl$list()
  expect_identical(cl$remove("self"), cl)
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


test_that("create conflicting proxies", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port)

  expect_error(
    cl$create("self", srv$port + 1),
    "While creating proxy 'self', toxiproxy errored",
    class = "toxiproxy_error")
  expect_error(
    cl$create("self2", srv$port, srv$port),
    "While creating proxy 'self2', toxiproxy errored",
    class = "toxiproxy_error")
})


test_that("get missing proxy", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  expect_error(
    cl$get("self"),
    "While fetching proxy 'self', toxiproxy errored",
    class = "toxiproxy_error")
})


test_that("remove missing proxy", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  expect_error(
    cl$remove("self"),
    "While removing proxy 'self', toxiproxy errored",
    class = "toxiproxy_error")
})


test_that("populate proxies", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  d <- data_frame(name = "self", listen = 0, upstream = srv$port)
  cl$populate(d)
  res <- cl$list()
  expect_equal(nrow(res), 1)
  expect_equal(res$name, "self")
  expect_equal(res$upstream, paste(cl$api()$host, srv$port, sep = ":"))
  expect_true(res$enabled)
  expect_equal(res$toxics, 0L)
})


test_that("check validate populate proxy data", {
  expect_error(
    check_populate_data(data_frame(name = "self")),
    "Missing required fields in 'data': 'listen', 'upstream'")
  expect_error(
    check_populate_data(data_frame(name = 0, upstream = 0, listen = 0)),
    "'data$name' must be a character", fixed = TRUE)

  d <- data_frame(name = "self", upstream = 8474, listen = 0, other = TRUE)
  expect_equal(
    check_populate_data(d, "localhost"),
    data_frame(name = "self",
               listen = "localhost:0",
               upstream = "localhost:8474"))

  d <- data_frame(name = c("a", "b"),
                  upstream = c(8474, "server:80"),
                  listen = 0)
  expect_equal(
    check_populate_data(d, "localhost"),
    data_frame(name = c("a", "b"),
               listen = "localhost:0",
               upstream = c("localhost:8474", "server:80")))
})
