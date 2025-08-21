#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
int fibonacci_ext(int n) {
  if (n < 2) {
    return (n);
  } else {
    return (fibonacci_ext(n - 1) + fibonacci_ext(n - 2));
  }
}