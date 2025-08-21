# ===== USING RCPP FOR PERFORMANCE =====
# This script demonstrates how to use Rcpp to speed up R code

# ===== 1. INLINE C++ WITH CPPFUNCTION =====
# R version of Fibonacci
fibonacci_r <- function(n) {
  if (n < 2) {
    return(n)
  } else {
    return(fibonacci_r(n - 1) + fibonacci_r(n - 2))
  }
}

# C++ version using Rcpp
library(Rcpp)
fibonacci_cpp <- cppFunction(
  "int fibonacci_cpp(int n){
    if (n < 2){
      return(n);
    } else {
      return(fibonacci_cpp(n - 1) + fibonacci_cpp(n - 2));
    }
  }"
)

# Compare performance
library(microbenchmark)
microbenchmark(
  r = fibonacci_r(30),
  rcpp = fibonacci_cpp(30),
  times = 10
)

# ===== 2. EXTERNAL C++ FILE =====
# Source the external C++ file with our Fibonacci implementation
sourceCpp("R/live_demo/fibonacci.cpp")

# Test the external function
fibonacci_ext(30)

# Compare all three implementations
microbenchmark(
  r = fibonacci_r(30),
  rcpp_inline = fibonacci_cpp(30),
  rcpp_external = fibonacci_ext(30),
  times = 10
)
