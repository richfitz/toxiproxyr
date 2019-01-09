##' @section Methods:
##'
##' \describe{
##' \item{\code{api}}{
##'   Returns an api client object that can be used to directly interact with the toxiproxy server.
##'
##'   \emph{Usage:}\cr\code{api()}
##' }
##' \item{\code{server_version}}{
##'   Returns the server version as a \code{numeric_version} object.
##'
##'   \emph{Usage:}\cr\code{server_version(refresh = FALSE)}
##'
##'   \emph{Arguments:}
##'   \itemize{
##'     \item{\code{refresh}:   Logical scalar indicating if the value should be refreshed from the server if it has already been retrieved, as it is not expected to change.
##'     }
##'   }
##' }
##' \item{\code{list}}{
##'   List information about all proxies on this server.  Returns a data.frame.
##'
##'   \emph{Usage:}\cr\code{list()}
##' }
##' \item{\code{create}}{
##'   Create a new proxy.
##'
##'   \emph{Usage:}\cr\code{create(name, upstream, listen = NULL, enabled = TRUE)}
##'
##'   \emph{Arguments:}
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
##'
##'   \emph{Value}:
##'   Returns a \code{\link{toxiproxy_proxy}} object - see the help there for details of methods that can be used with that object.
##' }
##' \item{\code{reset}}{
##'   Enable all proxies and remove all toxics.
##'
##'   \emph{Usage:}\cr\code{reset()}
##' }
##' \item{\code{get}}{
##'   Get an existing proxy
##'
##'   \emph{Usage:}\cr\code{get(name)}
##'
##'   \emph{Arguments:}
##'   \itemize{
##'     \item{\code{name}:   The name of the proxy to get
##'     }
##'   }
##'
##'   \emph{Value}:
##'   Returns a \code{\link{toxiproxy_proxy}} object - see the help there for details of methods that can be used with that object.
##' }
##' \item{\code{remove}}{
##'   Remove a proxy
##'
##'   \emph{Usage:}\cr\code{remove(name)}
##'
##'   \emph{Arguments:}
##'   \itemize{
##'     \item{\code{name}:   The name of the proxy to remove
##'     }
##'   }
##' }
##' }
