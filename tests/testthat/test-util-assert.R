context("util (assert)")

test_that("assert_scalar", {
  object <- 1:5
  expect_error(assert_scalar(object), "'object' must be a scalar")

  expect_error(assert_scalar(NULL), "must be a scalar")

  expect_silent(assert_scalar(TRUE))
})


test_that("assert_character", {
  object <- NULL
  expect_error(assert_character(object), "'object' must be a character")

  expect_error(assert_character(1), "must be a character")
  expect_error(assert_character(pi), "must be a character")

  expect_silent(assert_character("a"))
})


test_that("assert_integer", {
  expect_error(assert_integer(pi), "'pi' must be integer")
  expect_silent(assert_integer(1L))
  expect_silent(assert_integer(1))
  expect_silent(assert_integer(1 + 1e-15))
})


test_that("assert_logical", {
  expect_error(assert_logical(pi), "'pi' must be a logical")
  expect_silent(assert_logical(TRUE))
  expect_silent(assert_logical(FALSE))
})


test_that("match_value", {
  expect_error(match_value("foo", letters), "must be one of 'a', 'b'")
  expect_silent(match_value("a", letters))
})


test_that("assert_scalar_logical", {
  expect_true(assert_scalar_logical(TRUE))
  expect_error(assert_scalar_logical("1", "data"),
               "'data' must be a logical")
})


test_that("assert_scalar_integer", {
  expect_equal(assert_scalar_integer(1), 1)
  expect_error(assert_scalar_integer("1", name = "data"),
               "'data' must be integer")
})


test_that("assert_scalar_character", {
  expect_equal(assert_scalar_character("string"), "string")
  expect_error(assert_scalar_character(TRUE, "data"),
               "'data' must be a character")
})


test_that("assert_file_exists", {
  path <- tempfile()
  expect_error(assert_file_exists(path),
               "The path '.+?' does not exist")
  file.create(path)
  expect_silent(assert_file_exists(path))
})
