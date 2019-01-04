context("api client")

test_that("toxiproxy_addr", {
  withr::with_envvar(c(TOXIPROXY_ADDR = NA_character_), {
    expect_error(toxiproxy_addr(NULL), "toxiproxy address not found")
  })

  expect_error(toxiproxy_addr("file://foo"),
               "Expected an http url for toxiproxy addr")
})
