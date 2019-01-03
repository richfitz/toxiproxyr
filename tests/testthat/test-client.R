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
