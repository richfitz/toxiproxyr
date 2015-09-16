context("toxiproxyr")

test_that("basic tests", {
  skip_if_not_installed("RedisAPI")
  con <- toxiproxy()
  expect_that(con, is_a("toxiproxy"))

  lapply(con$list(), con$delete)
  expect_that(con$list(), equals(character(0)))

  tox <- con$create("test_redis", upstream=6379, listen=22222)
  expect_that(tox, is_a("toxiproxy_proxy"))
  expect_that(con$list(), equals("test_redis"))
  cmp <- con$get("test_redis")
  expect_that(cmp, is_a("toxiproxy_proxy"))

  ## TODO: something for fetching the port from tox (listen_port and listen_host)?
  redis <- RedisAPI::hiredis(port=tox$listen_port)
  expect_that(redis$PING(), equals("PONG"))

  set <- tox$toxics()
  expect_that(length(set), equals(0))
  expect_that(set, is_a("toxic_set"))

  expect_that(length(tox$toxics(TRUE)), is_more_than(0))

  t <- 300
  dat <- toxic_set(upstream=list(latency(t), bandwidth(56)))
  expect_that(dat, is_a("toxic_set"))

  expect_that(tox$with(dat, redis$PING()),
              takes_more_than(0.9 * t / 1000))

  ## This will crash R, as expected, as the RcppRedis package does not
  ## deal well with Redis failure.
  ##   tox$down(redis$PING())
})
