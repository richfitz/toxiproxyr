context("proxy")


test_that("Add toxic", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port, enabled = TRUE)
  expect_true(ping_self(p))

  p$add("latency", attributes = list(latency = 200))
  t1 <- system.time(ping_self(p), FALSE)[["elapsed"]]
  expect_gte(t1, 0.2)
})


test_that("list toxics (empty)", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port, enabled = TRUE)

  dat <- p$list()
  expect_equal(dat,
               data_frame(name = character(),
                          type = character(),
                          stream = character(),
                          toxicity = numeric(),
                          attributes = I(list())))
})


test_that("list toxics (nonempty)", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port, enabled = TRUE)
  p$add("latency", name = "slowdown", attributes = list(latency = 200))
  dat <- p$list()
  expect_equal(
    dat,
    data_frame(name = "slowdown",
               type = "latency",
               stream = "downstream",
               toxicity = 1,
               attributes = I(list(list(latency = 200, jitter = 0)))))
})


test_that("Remove toxic", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port, enabled = TRUE)
  nm <- p$add("latency", attributes = list(latency = 200))
  expect_identical(p$remove(nm), p)
  expect_equal(nrow(p$list()), 0)
})


test_that("toxic info", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port, enabled = TRUE)
  nm <- p$add("latency", attributes = list(latency = 200))
  p$info(nm)
})


test_that("update toxic", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port, enabled = TRUE)
  nm <- p$add("latency", attributes = list(latency = 200))
  p$update_toxic(nm, attributes = list(latency = 400, jitter = 20))
  dat <- p$info(nm)$attributes
  expect_equal(dat$latency, 400)
  expect_equal(dat$jitter, 20)
})


test_that("toxicity must be in [0, 1]", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port, enabled = TRUE)
  expect_error(
    p$add("latency", toxicity = -1, attributes = list(latency = 200)),
    "'toxicity' must lie in the range [0, 1]",
    fixed = TRUE)
  expect_error(
    p$add("latency", toxicity = 100, attributes = list(latency = 200)),
    "'toxicity' must lie in the range [0, 1]",
    fixed = TRUE)
})


test_that("update enabled", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port, enabled = TRUE)
  p$enabled <- FALSE
  expect_false(p$enabled)
  expect_false(cl$list()$enabled)
})


test_that("update listen", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port, enabled = TRUE)
  listen <- free_port(srv$port)
  p$listen <- listen
  expect_equal(sub(".+:", "", p$listen), as.character(listen))
  expect_equal(cl$list()$listen, p$listen)
  expect_equal(p$listen_port, listen)
})


test_that("update listen_port", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port, enabled = TRUE)
  listen <- free_port(srv$port)

  p$listen_port <- listen
  expect_equal(p$listen_port, listen)
  expect_equal(sub(".+:", "", p$listen), as.character(listen))
  expect_equal(cl$list()$listen, p$listen)
})


test_that("update upstream", {
  srv1 <- toxiproxy_server()
  srv2 <- toxiproxy_server()

  cl <- srv1$client()
  p <- cl$create("self", srv1$port, enabled = TRUE)

  upstream <- sub("[0-9]+$", srv2$port, p$upstream)
  p$upstream <- upstream

  expect_equal(p$upstream, upstream)
  expect_equal(cl$list()$upstream, p$upstream)
})



test_that("actions after proxy removal", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port)
  cl$remove("self")

  expect_error(
    p$describe(),
    "While fetching proxy 'self', toxiproxy errored",
    class = "toxiproxy_error")
  expect_error(
    p$list(),
    "While listing toxics for proxy 'self', toxiproxy errored",
    class = "toxiproxy_error")
  expect_error(
    p$remove("tox"),
    "While removing toxic 'tox' from proxy 'self', toxiproxy errored",
    class = "toxiproxy_error")
  expect_error(
    p$info("tox"),
    "While fetching toxic 'tox' from proxy 'self', toxiproxy errored",
    class = "toxiproxy_error")
  expect_error(
    p$update_toxic("tox", list(latency = 1)),
    "While updating toxic 'tox' for proxy 'self', toxiproxy errored",
    class = "toxiproxy_error")
  expect_error(
    p$update_proxy(),
    "While updating proxy 'self', toxiproxy errored",
    class = "toxiproxy_error")
})


test_that("toxics interface", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port)

  p$add(latency(10))
  d <- p$list()
  expect_equal(d$type, "latency")
  expect_equal(d$attributes[[1]]$latency, 10)
  expect_equal(d$attributes[[1]]$jitter, 0)
})


test_that("toxics interface requires empty attributes", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port)

  expect_error(
    p$add(latency(10), attributes = list(jitter = 5)),
    "'attributes' must be empty when using a toxic object")
})


test_that("with_down temporarily disables proxy", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port)

  expect_true(ping_self(p))
  expect_false(p$with_down(ping_self(p)))
  expect_true(ping_self(p))
})


test_that("clear proxy", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  p <- cl$create("self", srv$port)

  p$add(latency(200), "upstream")
  p$add(latency(200), "downstream")
  p$clear()
  expect_equal(nrow(p$list()), 0)
})
