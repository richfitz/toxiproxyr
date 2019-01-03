if (identical(Sys.getenv("TRAVIS"), "true") &&
    identical(Sys.getenv("TOXIPROXYR_SERVER_INSTALL"), "true")) {
  toxiproxy_server_install()
}
