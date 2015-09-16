# toxiproxyr

> Client for 'toxiproxy'

[![Linux Build Status](https://travis-ci.org//toxiproxyr.svg?branch=master)](https://travis-ci.org//toxiproxyr)

Client for 'toxiproxy' and possibly for 'toxi'.  The title is only a working one for now.

`toxiproxy` is an unfathful proxy; it forwards data to and from a service with various "toxic" attributes.  The data might be delayed (simulating a slow network connection), dropping the connection, restricting total bandwidth, and other bits of pollution.  These can be added together.

The design is a bit weird because the entire point of this package is to make side effects happen to things that are probably meant to do side effects.  So don't expect a composable pure functional interface.

## Interface

`toxiproxyr` requires the `toxiproxy` server to be running.  You will need to know the host and port if you've changed them from the defaults.


```r
library(toxiproxyr)
con <- toxiproxy()
```



Create a redis forwarder:


```r
tox <- con$create("test_redis", upstream=6379, listen=22222)
```

We can connect a Redis client to 22222 and it will forward to 6379


```r
redis <- RedisAPI::hiredis(port=tox$listen_port)
redis$PING()
```

```
## [1] "PONG"
```

```r
system.time(redis$PING())
```

```
##    user  system elapsed
##       0       0       0
```

Then, simulate the server going down (this will actually crash R as RcppRedis does not deal with this well)

```r
tox$down(redis$PING())
```

Create a set of toxics with a 300ms delay


```r
dat <- toxic_set(upstream=latency(300))
```

And run the Redis connection with this slower connection (look at `elapsed`):

```r
system.time(tox$with(dat, redis$PING()))
```

```
##    user  system elapsed
##   0.021   0.000   0.323
```

Clean up (everything; I don't see an endpoint for cleaning up a single branch)


```r
con$reset()
```

## Installation

```r
devtools::install_github("richfitz/toxiproxyr")
```

## License

MIT + file LICENSE © [Rich FitzJohn](https://github.com/richfitz).
