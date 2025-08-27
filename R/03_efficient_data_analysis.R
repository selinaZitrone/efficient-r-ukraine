# Load packages

library(microbenchmark) # for benchmarking code performance
library(tidyverse) # for data manipulation and import
library(data.table) # for data manipulation and import
library(arrow) # for efficient data import/export
library(collapse) # super fast data manipulation

# Define paths to data in different formats (315,840 rows and 8 columns)
file_path_csv <- here::here("data/ghg_ems.csv")
file_path_xlsx <- here::here("data/ghg_ems.xlsx")
file_path_parquet <- here::here("data/ghg_ems.parquet")
file_path_fst <- here::here("data/ghg_ems.fst")

# 1 Reading and writing data ---------------------------------------------------

# Additional arguments show_col_types and showProgress are just there to
# make the benchmarks fair. Normally you can omit them
compare_read <- microbenchmark(
  # base R
  read.csv = read.csv(file_path_csv),

  # tidyverse
  read_csv = readr::read_csv(file_path_csv, show_col_types = FALSE),
  read_excel = readxl::read_excel(file_path_xlsx),

  # data.table
  fread = data.table::fread(file_path_csv, showProgress = FALSE),

  # arrow
  read_csv_arrow = arrow::read_csv_arrow(file_path_csv),
  times = 10
)

summary(compare_read, unit = "relative")

autoplot(compare_read)

# Or use binary file types for even faster reading (especially as file size
# increases!)

compare_read_binary <- microbenchmark(
  # tidyverse
  read_csv = readr::read_csv(file_path_csv, show_col_types = FALSE),

  # data.table
  read_fread = data.table::fread(
    file_path_csv,
    showProgress = FALSE
  ),

  # arrow parquet format (binary)
  read_parquet = arrow::read_parquet(file_path_parquet),

  # fst format (efficient R only format)
  read_fst = fst::read_fst(file_path_fst),
  times = 10
)

autoplot(compare_read_binary)


# Writing data is similar ------------------------------------------------------
# Create sample data
# create an example with 1000000 rows to export
df <- data.frame(x = 1:1000000, y = 1:1000000, z = 1:1000000)

# Write the data using different functions
compare_write <- microbenchmark::microbenchmark(
  # write Excel
  write_excel = writexl::write_xlsx(df, "data/df.xlsx"),

  # write text
  write.csv = write.csv(df, "data/df.csv"),
  write_csv = readr::write_csv(df, "data/df.csv"),
  fwrite = data.table::fwrite(df, "data/df.csv"),
  write_csv_arrow = arrow::write_csv_arrow(df, "data/df.csv"),

  # write binary formats
  write_parquet = arrow::write_parquet(df, "data/df.parquet"),
  write_fst = fst::write_fst(df, "data/df.fst"),
  times = 10
)

autoplot(compare_write)

# 2 Data manipulation ---------------------------------------------------------

# Use the right data formats
ghg_ems <- readr::read_csv(file_path_csv)
ghg_ems_dt <- setDT(ghg_ems) # to data table
ghg_ems_parquet <- read_parquet(file_path_parquet, as_data_frame = FALSE)

summarize_dt <- function() {
  ghg_ems_dt[, mean(Electricity, na.rm = TRUE), by = Country]
}

# 2. The dplyr way
summarize_dplyr <- function() {
  ghg_ems |>
    group_by(Country) |>
    summarize(mean_e = mean(Electricity, na.rm = TRUE))
}

# 3. The collapse way
summarize_collapse <- function() {
  ghg_ems |>
    fgroup_by(Country) |>
    fsummarise(mean_e = fmean(Electricity))
}

# 4. The Arrow way
summarize_arrow <- function() {
  # Perform aggregation using Arrow's compute engine
  ghg_ems_parquet |>
    group_by(Country) |>
    summarize(mean_e = mean(Electricity, na.rm = TRUE)) |>
    collect()
}

# compare the speed of all versions
compare_summarize <- microbenchmark(
  dplyr = summarize_dplyr(),
  data_table = summarize_dt(),
  collapse = summarize_collapse(),
  arrow = summarize_arrow(),
  times = 10
)

summary(compare_summarize, unit = "relative")

# A bigger example ------------------------------------------------

# Create a larger dataset (10 million rows)
set.seed(123)
big_df <- tibble(
  id = rep(1:1000, each = 10000),
  group1 = sample(letters[1:5], 10000000, replace = TRUE),
  group2 = sample(LETTERS[1:20], 10000000, replace = TRUE),
  value1 = rnorm(10000000),
  value2 = runif(10000000),
  value3 = rexp(10000000)
)

# Convert to different formats
big_df_dt <- setDT(copy(big_df))
# write the big data as parquet file
arrow::write_parquet(big_df, "data/big_df.parquet")
# read the big data as arrow table (without converting to data frame)
big_df_arrow <- arrow::read_parquet(
  "data/big_df.parquet",
  as_data_frame = FALSE
)

# Complex operation: multiple grouping, window functions, filtering,
# and multiple aggregations
complex_dplyr <- function() {
  big_df |>
    group_by(group1, group2) |>
    mutate(
      centered = value1 - mean(value1),
      zscore = (value1 - mean(value1)) / sd(value1)
    ) |>
    summarize(
      mean_v1 = mean(value1, na.rm = TRUE),
      median_v2 = median(value2, na.rm = TRUE),
      sd_v3 = sd(value3, na.rm = TRUE),
      q95 = quantile(value1, 0.95),
      .groups = "drop"
    )
}

complex_data_table <- function() {
  big_df_dt[,
    # Calculate intermediate values for each group
    `:=`(
      centered = value1 - mean(value1),
      zscore = (value1 - mean(value1)) / sd(value1),
      n = .N
    ),
    by = .(group1, group2)
  ][,
    # Calculate summary statistics for filtered data
    .(
      mean_v1 = mean(value1, na.rm = TRUE),
      median_v2 = median(value2, na.rm = TRUE),
      sd_v3 = sd(value3, na.rm = TRUE),
      q95 = quantile(value1, 0.95)
    ),
    by = .(group1, group2)
  ]
}

complex_collapse <- function() {
  big_df |>
    fgroup_by(group1, group2) |>
    fmutate(
      n = fnobs(value1),
      centered = value1 - fmean(value1),
      zscore = (value1 - fmean(value1)) / fsd(value1)
    ) |>
    fsummarise(
      mean_v1 = fmean(value1, na.rm = TRUE),
      median_v2 = fmedian(value2, na.rm = TRUE),
      sd_v3 = fsd(value3, na.rm = TRUE),
      q95 = fquantile(value1, 0.95)
    )
}

complex_data_table_collapse <- function() {
  big_df_dt[,
    # Calculate intermediate values for each group
    `:=`(
      centered = value1 - fmean(value1),
      zscore = (value1 - fmean(value1)) / fsd(value1),
      n = .N
    ),
    by = .(group1, group2)
  ][,
    # Calculate summary statistics for filtered data
    .(
      mean_v1 = fmean(value1, na.rm = TRUE),
      median_v2 = fmedian(value2, na.rm = TRUE),
      sd_v3 = fsd(value3, na.rm = TRUE),
      q95 = fquantile(value1, 0.95)
    ),
    by = .(group1, group2)
  ]
}

complex_arrow <- function() {
  big_df_arrow |>
    group_by(group1, group2) |>
    mutate(
      centered = value1 - mean(value1),
      zscore = (value1 - mean(value1)) / sd(value1)
    ) |>
    summarize(
      mean_v1 = mean(value1, na.rm = TRUE),
      median_v2 = median(value2, na.rm = TRUE),
      sd_v3 = sd(value3, na.rm = TRUE),
      q95 = quantile(value1, 0.95),
      .groups = "drop"
    )
}

# Compare (run with fewer times due to complexity)
compare_complex <- microbenchmark(
  dplyr = complex_dplyr(),
  data_table = complex_data_table(),
  data_table_collapse = complex_data_table_collapse(),
  collapse = complex_collapse(),
  arrow = complex_arrow(),
  times = 3
)

autoplot(compare_complex)
summary(compare_complex, unit = "relative")
