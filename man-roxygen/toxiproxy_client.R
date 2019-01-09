##' @section Methods:
##' \cr\describe{
##' \item{\code{api}}{
##'   Returns an api client object that can be used to directly interact with the toxiproxy server.
##'   \cr\emph{Usage:}\code{api()}
##' }
##' \item{\code{server_version}}{
##'   Returns the server version as a \code{numeric_version} object.
##'   \cr\emph{Usage:}\code{server_version(refresh = FALSE)}
##'   \cr\emph{Arguments:}
##'   \itemize{
##'     \item{\code{refresh}:   Logical scalar indicating if the value should be refreshed from the server if it has already been retrieved, as it is not expected to change.
##'     }
##'   }
##' }
##' \item{\code{list}}{
##'   List information about all proxies on this server.  Returns a data.frame.
##'   \cr\emph{Usage:}\code{list()}
##' }
##' \item{\code{create}}{
##'   Create a new proxy.
##'   \cr\emph{Usage:}\code{create(name, upstream, listen = NULL, enabled = TRUE)}
##'   \cr\emph{Arguments:}
##'   \itemize{
##'     \item{\code{name}:   The name for the proxy
##'     }
##'
##'     \item{\code{upstream}:   The address of the service to proxy.  Can be given as a string in the format \code{<host>:<port>} or simply as a port number, in which case the host is assumed to be \code{localhost}.
##'     }
##'
##'     \item{\code{listen}:   The address that the proxy should listen on.  Can be given as a either a string in the format \code{<host>:<port>} or simply as a port, in which case the host will be set to the same host as the toxiproxy server (which is almost always what you want!). If omitted, the toxiproxy server will choose a random free port.
##'     }
##'
##'     \item{\code{enabled}:   Logical scalar indicating if the proxy should be enabled after creation.
##'     }
##'   }
##'   \cr\emph{Value}:
##'   Returns a \code{\link{toxiproxy_proxy}} object - see the help there for details of methods that can be used with that object.
##' }
##' \item{\code{reset}}{
##'   Enable all proxies and remove all toxics.
##'   \cr\emph{Usage:}\code{reset()}
##' }
##' \item{\code{get}}{
##'   Get an existing proxy
##'   \cr\emph{Usage:}\code{get(name)}
##'   \cr\emph{Arguments:}
##'   \itemize{
##'     \item{\code{name}:   The name of the proxy to get
##'     }
##'   }
##'   \cr\emph{Value}:
##'   Returns a \code{\link{toxiproxy_proxy}} object - see the help there for details of methods that can be used with that object.
##' }
##' \item{\code{remove}}{
##'   Remove a proxy
##'   \cr\emph{Usage:}\code{remove(name)}
##'   \cr\emph{Arguments:}
##'   \itemize{
##'     \item{\code{name}:   The name of the proxy to remove
##'     }
##'   }
##' }
##' }
