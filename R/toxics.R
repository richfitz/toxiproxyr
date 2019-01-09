##' Helper functions for creating toxics for use with toxiproxy.
##' These can be passed as the first argument to \code{$add} on a
##' toxic proxy in lieu of the \code{type} and \code{attributes}
##' arguments.
##'
##' @title Toxics for use with toxiproxy
##' @name toxic
##' @rdname toxic
NULL

##' The \code{latency} toxic adds a delay to all data going through
##' the proxy. The delay is equal to \code{latency +/- jitter}.
##'
##' @param latency Latency in milliseconds
##' @param jitter Time in milliseconds
##' @export
##' @rdname toxic
latency <- function(latency, jitter = 0) {
  toxic("latency",
        latency = assert_scalar_integer(latency),
        jitter = assert_scalar_integer(jitter))
}


##' The \code{bandwidth} toxic limits a connection to a maximum number
##' of kilobytes per second.
##' @param rate Rate in KB per second
##' @export
##' @rdname toxic
bandwidth <- function(rate) {
  toxic("bandwidth", rate = assert_scalar_integer(rate))
}


##' The \code{slow_close} toxic delays the TCP socket from closing
##' until delay has elapsed.
##' @param delay Time in milliseconds
##' @export
##' @rdname toxic
slow_close <- function(delay) {
  toxic("slow_close", delay = assert_scalar_integer(delay))
}


##' The \code{timeout} toxic stops all data from getting through, and
##' closes the connection after \code{timeout}. If timeout is 0, the
##' connection won't close, and data will be delayed until the toxic
##' is removed.
##' @param timeout Time in milliseconds
##' @export
##' @rdname toxic
timeout <- function(timeout) {
  toxic("timeout", timeout = assert_scalar_integer(timeout))
}


##' The \code{slicer} toxic slices TCP data up into small bits,
##' optionally adding a delay between each sliced "packet".
##' @param average_size Size in bytes of an average packet
##' @param size_variation Variation in bytes of an average packet
##'   (should be smaller than \code{average_size})
##' @export
##' @rdname toxic
slicer <- function(average_size, size_variation, delay = 0) {
  toxic("slicer",
        average_size = assert_scalar_integer(average_size),
        size_variation = assert_scalar_integer(size_variation),
        delay = assert_scalar_integer(delay))
}


##' The \code{limit_data} toxic closes the connection when transmitted
##' data exceeded limit.
##' @param bytes The number of bytes it should transmit before
##'   connection is closed
##' @export
##' @rdname toxic
limit_data <- function(bytes) {
  toxic("limit_data", bytes = assert_scalar_integer(bytes))
}


toxic <- function(type, ...) {
  structure(list(type = type, attributes = list(...)), class = "toxic")
}


##' @export
format.toxic <- function(x, ...) {
  options <- paste(sprintf('"%s": %s',
                           names(x$attributes),
                           vcapply(x$attributes, as.character)),
                   collapse = ", ")
  sprintf("Toxic '%s' with attributes {%s}", x$type, options)
}


##' @export
print.toxic <- function(x, ...) {
  cat(paste0(format.toxic(x), "\n"))
  invisible(x)
}
