##' @rdname toxiproxy_server
##'
##' @param quiet Suppress progress bars on install
##'
##' @param version Version of toxiproxy to install
##'
##' @export
toxiproxy_server_install <- function(quiet = FALSE, version = "v2.1.3") {
  if (!identical(Sys.getenv("NOT_CRAN"), "true")) {
    stop("Do not run this on CRAN")
  }
  if (!identical(Sys.getenv("TOXIPROXYR_SERVER_INSTALL"), "true")) {
    stop("Please read the documentation for toxiproxy_server_install")
  }
  path <- Sys_getenv("TOXIPROXYR_SERVER_BIN_PATH", NULL)
  if (is.null(path)) {
    stop("TOXIPROXYR_SERVER_BIN_PATH is not set")
  }
  dir.create(path, FALSE, TRUE)
  dest <- file.path(path, "toxiproxy")
  if (file.exists(dest)) {
    message("toxiproxy already installed at ", dest)
  } else {
    toxiproxy_install(path, quiet, version)
  }
  invisible(dest)
}


toxiproxy_platform <- function(sysname = Sys.info()[["sysname"]]) {
  switch(sysname,
         Darwin = "darwin",
         Windows = "windows",
         Linux = "linux",
         stop("Unknown sysname"))
}


toxiproxy_url <- function(version, platform = toxiproxy_platform(),
                          arch = "amd64") {
  url_root <- "https://github.com/Shopify/toxiproxy/releases/download/"
  fmt <- "%s/toxiproxy-server-%s-%s%s"
  ext <- if (platform == "windows") ".exe" else ""
  paste0(url_root, sprintf(fmt, version, platform, arch, ext))
}


toxiproxy_install <- function(dest, quiet, version) {
  dest_bin <- file.path(dest, "toxiproxy")
  if (!file.exists(dest_bin)) {
    message(sprintf("installing toxiproxy to '%s'", dest))
    url <- toxiproxy_url(version)
    exe <- download_file(url, quiet = quiet)
    ok <- file.copy(exe, dest_bin)
    Sys.chmod(dest_bin, "755")
  }
  invisible(dest_bin)
}
