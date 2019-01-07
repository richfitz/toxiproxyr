context("http")

test_that("prepare_path", {
  expect_equal(prepare_path("foo"), "/foo")
  expect_equal(prepare_path("/foo"), "/foo")
})


test_that("unknown endpoint", {
  srv <- toxiproxy_server()
  cl <- srv$client()
  expect_error(
    cl$api()$GET("fetching missing page", "foobar"),
    "While fetching missing page, toxiproxy errored because http error",
    class = "toxiproxy_error")
})
