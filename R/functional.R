with_down <- function(tox, expr) {
  tox$down(expr)
}

with_proxy <- function(tox, set, expr) {
  tox$with(set, expr)
}
