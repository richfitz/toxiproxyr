##' @section Methods:
##'
##' \describe{
##' \item{\code{name}}{
##'   The name of the proxy (a string).  This is used in methods \code{$get} and \code{remove} of \code{\link{toxiproxy_client}}. This field is read only.
##' }
##' \item{\code{listen}}{
##'   The address that the proxied service is available on.  This will be in the form \code{host:port} (e.g., \code{localhost:22222}. The field \code{listen_port} give the port number separately. Assigning to this field will update the listen address of the proxy (equivalent to using \code{$update_proxy}).
##' }
##' \item{\code{listen_port}}{
##'   The port that the proxied service is available on.  Assigning to this field will update the listen address of the proxy (equivalent to using \code{$update_proxy}), but will retain the current hostname.
##' }
##' \item{\code{upstream}}{
##'   The address that the upstream service (that is being proxied) is found at.  The toxic proxy forwards traffic here.  This will in the form \code{host:port} (e.g., \code{localhost:80}.  Assigning to this field will update the upstream address of the proxy (equivalent to using \code{$update_proxy}).
##' }
##' \item{\code{enabled}}{
##'   Logical scalar, indicating if the proxy is enabled (i.e., allowing traffic).  If a proxy is enabled then all toxics on that proxy are enabled.  Assigning to this field enables or disables the proxy (with a value of \code{TRUE} and \code{FALSE} respectively), equivalent to using \code{$update_proxy}.
##' }
##' \item{\code{describe}}{
##'   Query for the current information about this proxy.  Returns a named list.
##'
##'   \emph{Usage:}\cr\code{describe()}
##' }
##' \item{\code{add}}{
##'   Add toxics to the proxy.  Returns the name of the created toxic.
##'     Use \code{$list())} to see what has been added to the proxy.
##'
##'   \emph{Usage:}\cr\code{add(type, stream = "downstream", toxicity = 1, attributes = list(),
##'       name = NULL)}
##'
##'   \emph{Arguments:}
##'   \itemize{
##'     \item{\code{type}:   Either a \code{\link{toxic}} object (e.g., \code{\link{latency}}) or the name of one as a scalar character.
##'     }
##'
##'     \item{\code{stream}:   The stream to apply the proxy to.  Must be either \code{"downstream"} (the default) or \code{"upstream"}).
##'     }
##'
##'     \item{\code{toxicity}:   Scalar numeric indicating the \emph{probability} of the proxy being applied to the connection.
##'     }
##'
##'     \item{\code{attributes}:   If \code{type} is a character string, a named list of attributes (see \href{https://github.com/shopify/toxiproxy#toxics}{the toxiproxy documentation}).  If \code{type} is a \code{toxic} object this must be empty.
##'     }
##'
##'     \item{\code{name}:   Name to call the toxic.  If omitted, the toxiproxy server will generate a name automatically.
##'     }
##'   }
##' }
##' \item{\code{list}}{
##'   List toxics that have been added to the proxy.  This will be returned as a \code{data.frame}.
##'
##'   \emph{Usage:}\cr\code{list()}
##' }
##' \item{\code{remove}}{
##'   Remove a toxic from the proxy.
##'
##'   \emph{Usage:}\cr\code{remove(name)}
##'
##'   \emph{Arguments:}
##'   \itemize{
##'     \item{\code{name}:   Name of the toxic to remove - use \code{names($list())} to get a list of names of toxics present for a proxy.
##'     }
##'   }
##' }
##' \item{\code{info}}{
##'   Get information about a toxic from the proxy by name.  This returns a named list.
##'
##'   \emph{Usage:}\cr\code{info(name)}
##'
##'   \emph{Arguments:}
##'   \itemize{
##'     \item{\code{name}:   A single string with the name of the toxic to be retrieved.  It is an error to try and get an nonexistant toxic.
##'     }
##'   }
##' }
##' \item{\code{update_toxic}}{
##'   Update attributes of a toxic
##'
##'   \emph{Usage:}\cr\code{update_toxic(name, attributes)}
##'
##'   \emph{Arguments:}
##'   \itemize{
##'     \item{\code{name}:   Name of the toxic to update.
##'     }
##'
##'     \item{\code{attributes}:   A named list of attributes for the toxic.  Use \code{$info()} to see what is valid for your toxic, or see \href{https://github.com/shopify/toxiproxy#toxics}{the toxiproxy documentation}.
##'     }
##'   }
##' }
##' \item{\code{update_proxy}}{
##'   Update attributes of the proxy.  Values not provided will not be modified from their current values.
##'
##'   \emph{Usage:}\cr\code{update_proxy(upstream = NULL, listen = NULL, enabled = NULL)}
##'
##'   \emph{Arguments:}
##'   \itemize{
##'     \item{\code{upstream}:   Upstream address in the format \code{<host>:<port>}
##'     }
##'
##'     \item{\code{listen}:   Listen address in the format \code{<host>:<port>}
##'     }
##'
##'     \item{\code{enabled}:   Logical scalar indicating if the proxy should be enabled
##'     }
##'   }
##' }
##' \item{\code{with_down}}{
##'   Like \code{$with}, this runs an R expression with the proxy temporarily down (so that no traffic can be transmitted or recieved).  The state of the proxy will be restored after the expression has evaluated, even if it throws an error.
##'
##'   \emph{Usage:}\cr\code{with_down(expr)}
##'
##'   \emph{Arguments:}
##'   \itemize{
##'     \item{\code{expr}:   An R expression that will be run with the proxy disabled.
##'     }
##'   }
##' }
##' }
