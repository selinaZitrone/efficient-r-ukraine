# load packages
library(microbenchmark)

# Vectorize your code ----------------------------------------------------------

# Example 1: Vector arithmetic vs. for loop
x <- 1:1e6
y <- 1:1e6

microbenchmark(
  for_loop = {
    result <- numeric()
    for (i in seq_along(x)) {
      result[i] <- x[i] * 2 + y[i] / 2
    }
  },
  vectorized = x * 2 + y / 2,
  times = 10
)

# Example 2: Calculating cumulative values
x <- sample(1:100, 1e6, replace = TRUE)

microbenchmark(
  for_loop = {
    result <- numeric()
    sum_so_far <- 0
    for (i in seq_along(x)) {
      sum_so_far <- sum_so_far + x[i]
      result[i] <- sum_so_far
    }
  },
  vectorized = cumsum(x),
  times = 10
)

# For-loops --------------------------------------------------------------------
# Don't grow objects in a loop
# Preallocate memory if you know how big it will be

f1 <- function() {
  x <- numeric()
  for (i in 1:1e6) {
    x[i] <- i
  }
}

# Fill up data frame in a loop but pre-allocate it
f2 <- function() {
  x <- numeric(1e6)
  for (i in 1:1e6) {
    x[i] <- i
  }
}

compare_alloc <- microbenchmark(
  no_alloc = f1(),
  pre_alloc = f2(),
  times = 10
)

summary(compare_alloc, unit = "relative")

# Why? R is making copies of the object to grow it
# x is initially empty, y is initialized with length 10
x <- numeric()
y <- numeric(10)

for (i in 1:10) {
  x[i] <- i
  y[i] <- i

  # Print current memory location after each assignment
  cat(
    "After iteration ",
    i,
    ": x is in ",
    pryr::address(x),
    "and y is in ",
    pryr::address(y),
    "\n"
  )
}

# Caching variables ------------------------------------------------------------
# Don't recompute values unnecessarily
# Store results in variables if they'll be reused

x <- matrix(rnorm(10000), ncol = 1000)

# calculate column means and normalize by standard deviation with and without caching
microbenchmark(
  no_cache = apply(x, 2, function(i) mean(i) / sd(x)),
  cache = {
    sd_x <- sd(x)
    apply(x, 2, function(i) mean(i) / sd_x)
  }
)
