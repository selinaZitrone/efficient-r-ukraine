# Profiling R code ----------------------------------------------------------
# Finding bottlenecks in the code

# install.packages("profvis")

library(profvis)

# Example: Centering data around its mean
profvis({
  # Create a data frame with 150 columns and 200000 rows
  df <- as.data.frame(matrix(rnorm(150 * 200000), nrow = 200000))

  # Calculate mean of each column
  means <- apply(df, 2, mean)

  # Subtract means
  for (i in seq_along(means)) {
    df[, i] <- df[, i] - means[i]
    # Simulate inefficiency by sleeping for 0.01 seconds
    Sys.sleep(0.01)
  }
})

# Benchmarking R code -------------------------------------------------------
# Measuring runtime

# Define some functions to compare

# Same function as above
center_data_slow <- function() {
  # Create a data frame with 150 columns and 100000 rows
  df <- as.data.frame(matrix(rnorm(150 * 100000), nrow = 100000))

  # Calculate mean of each column
  means <- apply(df, 2, mean)

  # Subtract means
  for (i in seq_along(means)) {
    df[, i] <- df[, i] - means[i]
    # Simulate inefficiency by sleeping for 0.01 seconds
    Sys.sleep(0.01)
  }
  return(df)
}

# More efficient version
center_data_fast <- function() {
  # Create a data frame with 150 columns and 100000 rows
  df <- matrix(rnorm(150 * 100000), nrow = 100000)

  # Calculate mean of each column
  means <- colMeans(df)

  # Subtract means
  for (i in seq_along(means)) {
    df[, i] <- df[, i] - means[i]
  }
  return(df)
}

# Option 1: Quick benchmarking -------------------------------------------------

system.time(center_data_slow())
system.time(center_data_fast())

library(tictoc)

tic()
slow_data <- center_data_slow()
toc()

tic()
fast_data <- center_data_fast()
toc()

# Option 2: Using microbenchmark -----------------------------------------------

library(microbenchmark)

# Compare the runtime of the two functions
runtime_comp <- microbenchmark(
  slow = center_data_slow(),
  fast = center_data_fast(),
  times = 10 # the default is 100 but we are impatient
)

# Look at absolute runtimes
runtime_comp

# Get a relative comparison
summary(runtime_comp, unit = "relative")

# Plot the results
ggplot2::autoplot(runtime_comp)
