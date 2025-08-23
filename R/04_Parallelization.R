# This script demonstrates different methods for parallelization in R

# Load packages
library(tictoc) # For timing code execution
library(parallel) # For core detection and parallel processing
library(future) # For future.apply and other future functions

# Check how many cores are available on your system
parallel::detectCores()

# 1 A simple function for demonstration ---------------------------------------

# Create a deliberately slow function for testing parallelization
slow_sqrt <- function(x) {
  Sys.sleep(1) # simulate 1 second of computation time
  sqrt(x)
}

# Create a vector of 10 numbers
x <- 1:10

# 2 Using the future package for parallelization ------------------------------

# Set up a parallel backend (multisession uses multiple cores on same machine)
# Adjust the number of workers according to your system
future::plan(multisession, workers = 5)

# 3 Parallel apply functions --------------------------------------------------

# 3.1 Sequential lapply
tic()
result_sequential <- lapply(x, slow_sqrt)
toc()

# 3.2 Parallel lapply using future.apply
library(future.apply)
tic()
result_parallel <- future_lapply(x, slow_sqrt)
toc()

# Additional parallel apply functions:
# - future_sapply, future_vapply, future_mapply
# - future_tapply, future_apply, future_Map

# 4 Parallel for loops --------------------------------------------------------

# 4.1 Sequential for loop
tic()
z_for <- list()
for (i in 1:10) {
  z_for[[i]] <- slow_sqrt(i)
}
toc()

# 4.2 Sequential foreach
library(foreach)
tic()
z_foreach <- foreach(i = 1:10) %do%
  {
    slow_sqrt(i)
  }
toc()

# 4.3 Parallel foreach with doFuture
library(doFuture)

tic()
z_foreach_parallel <- foreach(i = 1:10) %dofuture%
  {
    slow_sqrt(i)
  }
toc()

# 5 Parallel purrr functions --------------------------------------------------

# 5.1 Sequential purrr
library(purrr)
tic()
z_purrr <- map(x, slow_sqrt)
toc()

# 5.2 Parallel purrr with furrr
library(furrr)
tic()
z_furrr <- future_map(x, slow_sqrt)
toc()

# Additional parallel purrr functions:
# - future_map_dbl, future_map_int, future_map_chr
# - future_map_lgl, future_map_dfr, future_map_dfc
# - future_map2, future_pmap, future_walk

# 6 Cleaning up ---------------------------------------------------------------
# Close the parallel backend when done
future::plan(sequential)
