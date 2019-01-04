context("http")

test_that("prepare_path", {
  expect_equal(prepare_path("foo"), "/foo")
  expect_equal(prepare_path("/foo"), "/foo")
})
