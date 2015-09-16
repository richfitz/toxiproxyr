##' Latency toxic.  Add a delay to all data going through the
##' proxy. The delay is equal to latency +/- jitter.
##' @title Latency toxic
##' @param latency Latency, in milliseconds (1000 = 1s)
##' @param jitter Variation, in milliseconds
##' @export
latency <- function(latency=0, jitter=0) {
  toxic("latency", list(latency=latency,
                        jitter=jitter))
}

##' Limit a connection to a maximum number of kilobytes per second.
##' @title Bandwidth toxic
##' @param rate rate in KB/s
##' @export
bandwidth <- function(rate=0) {
  toxic("bandwidth", list(rate=rate))
}

##' Delay the TCP socket from closing until delay has elapsed.
##' @title Delay TCP socket closure
##' @param delay time in milliseconds
##' @export
slow_close <- function(delay=0) {
  toxic("slow_close", list(delay=delay))
}

##' Stops all data from getting through, and close the connection
##' after timeout. If timeout is 0, the connection won't close, and
##' data will be delayed until the toxic is disabled.
##' @title Timeout toxic
##' @param timeout time in milliseconds
##' @export
timeout <- function(timeout=0) {
  toxic("timeout", list(timeout=timeout))
}

##' Slices TCP data up into small bits, optionally adding a delay
##' between each sliced "packet".
##' @title Slicer toxic
##' @param average_size size in bytes of an average packet
##' @param size_variation variation in bytes of an average packet
##' (should be smaller than average_size)
##' @param delay time in microseconds to delay each packet by
##' @export
slicer <- function(average_size=0, size_variation=0, delay=0) {
  toxic("slicer", list(average_size=average_size,
                       size_variation=size_variation,
                       delay=delay))
}

toxic <- function(name, data) {
  data <- list(name=name, data=data)
  assert_named(data$data, name="arguments to toxic")
  data <- data[names(data) != "enabled"]
  class(data) <- "toxic"
  data
}

is_toxic <- function(x) {
  inherits(x, "toxic")
}

##' Create a set of toxics to apply to a connection.
##'
##' The possible toxics are \code{\link{latency}},
##' \code{\link{bandwidth}}, \code{\link{slow_close}},
##' \code{\link{timeout}} and \code{\link{slicer}}.
##' @title Create a set of toxics
##' @param upstream Single toxic or list of toxics to apply to the
##'   upstream connection
##' @param downstream Single toxic or list of toxics to apply to the
##'   downstream connection
##' @export
##' @examples
##' toxic_set(timeout(1000))
##' # Simulate Australia:
##' toxic_set(upstream=list(bandwidth(10), latency(100)),
##'           downstream=list(bandwidth(50), latency(100)))
toxic_set <- function(upstream=NULL, downstream=NULL) {
  check <- function(x, direction) {
    if (is.null(x)) {
      list()
    } else if (is_toxic(x)) {
      list(add_direction(x, direction))
    } else if (all(vlapply(x, is_toxic))) {
      lapply(x, add_direction, direction)
    } else {
      stop(sprintf("All elements of %s must be toxic", direction))
    }
  }
  add_direction <- function(x, direction) {
    x$direction <- direction
    x
  }

  ret <- c(check(upstream, "upstream"),
           check(downstream, "downstream"))
  class(ret) <- "toxic_set"
  ret
}
