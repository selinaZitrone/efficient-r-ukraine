# Load packages
library(Rcpp) # For C++ integration in R
library(microbenchmark) # For benchmarking code performance

# 1 Inline C++ with cppFunction -----------------------------------------------

# Define R version of Fibonacci
fibonacci_r <- function(n) {
  if (n < 2) {
    return(n)
  } else {
    return(fibonacci_r(n - 1) + fibonacci_r(n - 2))
  }
}

# C++ version using Rcpp
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
compare_cpp_function <- microbenchmark(
  r = fibonacci_r(30),
  rcpp = fibonacci_cpp(30),
  times = 10
)

summary(compare_cpp_function, unit = "relative")

# 2 External C++ file ---------------------------------------------------------
# Source the external C++ file with our Fibonacci implementation
sourceCpp("R/fibonacci.cpp")

# Test the external function
fibonacci_ext(30)

# Compare all three implementations
microbenchmark(
  r = fibonacci_r(30),
  rcpp_inline = fibonacci_cpp(30),
  rcpp_external = fibonacci_ext(30),
  times = 10
)
