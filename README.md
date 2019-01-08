# toxiproxyr

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Linux Build Status](https://travis-ci.org/richfitz/toxiproxyr.svg?branch=master)](https://travis-ci.org/richfitz/toxiproxyr)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/richfitz/toxiproxyr?svg=true)](https://ci.appveyor.com/project/richfitz/toxiproxyr)
[![codecov.io](https://codecov.io/github/richfitz/toxiproxyr/coverage.svg?branch=master)](https://codecov.io/github/richfitz/toxiproxyr?branch=master)



`toxiproxy` is an unfathful proxy; it forwards data to and from a service with various "toxic" attributes.  The data might be delayed (simulating a slow network connection), dropping the connection, restricting total bandwidth, and other bits of pollution.  These can be added together.

## Target audience and use cases

`toxiproxy` is designed for use in tests; this package, as a client for `toxiproxy` the same.  It's primary uses will be for use in tests for packages that do things over the network.  For example:

* packages that develop new database drivers can use this to explore corner cases such as loss of the network connection, spotty connections, etc
* packages that make heavy use of the network over existing drivers might use the package to ensure reasonable performance over slow connections

I do not expect that this package will be of interest to the vast majority of R users, and I don't expect it to be useful within core package code.

## Interface

`toxiproxyr` requires a `toxiproxy` server to be running.  If you already have one configured, then you can set the environment variable `TOXIPROXY_ADDR` to point at the server and `toxiproxyr` will use this server when you run

```r
cl <- toxiproxyr::toxiproxy_client()
```

Alternatively, `toxiproxyr` can install a server for you - this is the interface designed for testing environments like [travis](https://travis-ci.org) and [appveyor](https://ci.appveyor.com).  In that case, set the environment variable `TOXIPROXYR_SERVER_INSTALL` to `true` and `TOXIPROXYR_SERVER_BIN_PATH` to the *directory* to install `toxiproxy` into.  Then, in the tests run


```r
srv <- toxiproxyr::toxiproxy_server()
```

which will give you a *brand new* toxiproxy server `srv` which will be deleted once the `srv` object goes out of scope (this is designed for use within `test_that` blocks.  Then create a client:


```r
cl <- srv$client()
```

To interact with the server, through the client, use the methods:


```r
cl
```

```
## <toxiproxy_client>
##   Public:
##     api: function ()
##     create: function (name, upstream, listen = NULL, enabled = TRUE)
##     get: function (name)
##     initialize: function (addr)
##     list: function ()
##     remove: function (name)
##     reset: function ()
##     server_version: function (refresh = FALSE)
##   Private:
##     api_client: toxiproxy_api_client, R6
```

For example, we might create an unreliable redis proxy:


```r
proxy <- cl$create("unreliable_redis", upstream = 6379)
```

Because no `listen` port was given, this runs on a random port:


```r
proxy$listen
```

```
## [1] "127.0.0.1:62511"
```

```r
proxy$listen_port
```

```
## [1] 62511
```

Connect a redis client to our new proxy


```r
redis <- redux::hiredis(port = proxy$listen_port)
redis$PING()
```

```
## [Redis: PONG]
```

We can simulate a slow connection by adding latency:


```r
system.time(redis$PING())[["elapsed"]]
```

```
## [1] 0.001
```

```r
proxy$add(toxiproxyr::latency(300))
```

```
## [1] "latency_downstream"
```

```r
system.time(redis$PING())[["elapsed"]]
```

```
## [1] 0.306
```

or simulate server or network failure by disabling the proxy entirely:


```r
proxy$with_down(redis$PING())
```

```
## Error in redis_command(ptr, cmd): Failure communicating with the Redis server
```

## Installation

Until the package is on CRAN, install from github

```r
remotes::install_github("richfitz/toxiproxyr", upgrade = FALSE)
```

## License

MIT + file LICENSE © [Rich FitzJohn](https://github.com/richfitz).

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/richfitz/stevedore/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.
