context("toxics")


test_that("latency", {
  expect_equal(
    latency(2, 1),
    toxic("latency", latency = 2, jitter = 1))
})


test_that("bandwidth", {
  expect_equal(
    bandwidth(20),
    toxic("bandwidth", rate = 20))
})


test_that("slow_close", {
  expect_equal(
    slow_close(30),
    toxic("slow_close", delay = 30))
})


test_that("timeout", {
  expect_equal(
    timeout(40),
    toxic("timeout", timeout = 40))
})


test_that("slicer", {
  expect_equal(
    slicer(10, 5, 2),
    toxic("slicer", average_size = 10, size_variation = 5, delay = 2))
})


test_that("limit_data", {
  expect_equal(
    limit_data(50),
    toxic("limit_data", bytes = 50))
})


test_that("format", {
  t <- latency(2, 1)
  str <- "Toxic 'latency' with attributes {\"latency\": 2, \"jitter\": 1}"
  expect_equal(format(t), str, fixed = TRUE)
  expect_output(res <- withVisible(print(t)), str, fixed = TRUE)
  expect_equal(res, list(value = t, visible = FALSE))
})
