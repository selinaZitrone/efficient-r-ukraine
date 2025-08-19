library(tictoc)


# Create a data frame with 150 columns and 2000000 rows
df <- matrix(rnorm(150 * 2000000), nrow = 2000000)

# Calculate mean of each column
means <- colMeans(df)

# Subtract means
for (i in seq_along(means)) {
  df[, i] <- df[, i] - means[i]
}
