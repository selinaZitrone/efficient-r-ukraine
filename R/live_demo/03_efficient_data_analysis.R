# Load packages

library(microbenchmark) # for benchmarking code performance
library(tidyverse) # for data manipulation and import
library(data.table) # for data manipulation and import
library(arrow) # for efficient data import/export
library(collapse) # super fast data manipulation

# 1 Reading and writing data ---------------------------------------------------

# path to a large csv file with 315,840 rows and 8 columns
file_path_csv <- here::here("data/ghg_ems_large.csv")
file_path_xlsx <- here::here("data/ghg_ems_large.xlsx")

# Additional arguments like progress = FALSE etc. are just there to make the benchmarks fair
# Normally you can omit them
compare_read <- microbenchmark(
  read.csv = read.csv(file_path_csv),
  read_csv = readr::read_csv(
    file_path_csv,
    show_col_types = FALSE
  ),
  fread = data.table::fread(file_path_csv, showProgress = FALSE),
  read_csv_arrow = arrow::read_csv_arrow(file_path_csv),
  read_excel = readxl::read_excel(file_path_xlsx),
  times = 10
)

summary(compare_read, unit = "relative")

autoplot(compare_read)

# Or use binary file types for even faster reading (especially as file size
# increases)

file_path_parquet <- here::here("data/ghg_ems_large.parquet")
file_path_fst <- here::here("data/ghg_ems_large.fst")

compare_read_binary <- microbenchmark(
  read_csv = readr::read_csv(file_path_csv, show_col_types = FALSE),
  read_fread = data.table::fread(
    file_path_csv,
    showProgress = FALSE
  ),
  read_parquet = arrow::read_parquet(file_path_parquet),
  read_fst = fst::read_fst(file_path_fst),
  times = 10
)

autoplot(compare_read_binary)


# Writing data is similar ------------------------------------------------------
# Create sample data
sample_data <- data.table::fread(file_path_csv)

# Write the data using different functions
compare_write <- microbenchmark::microbenchmark(
  write.csv = write.csv(sample_data, "data/dummy_df.csv"),
  write_csv = readr::write_csv(sample_data, "data/dummy_df.csv"),
  fwrite = data.table::fwrite(sample_data, "data/dummy_df.csv"),
  write_excel = writexl::write_xlsx(sample_data, "data/dummy_df.xlsx"),
  write_csv_arrow = arrow::write_csv_arrow(sample_data, "data/dummy_df.csv"),

  # Write binary formats
  write_parquet = arrow::write_parquet(sample_data, "data/dummy_df.parquet"),
  write_fst = fst::write_fst(sample_data, "data/dummy_df.fst"),

  times = 10
)

autoplot(compare_write)

# Binary formats
# Especially useful when data becomes really big

# Writing binary formats
compare_write_binary <- microbenchmark(
  write_rds = readr::write_rds(sample_data, "data/dummy_df.rds"),
  write_parquet = arrow::write_parquet(sample_data, "data/dummy_df.parquet"),
  write_fst = fst::write_fst(sample_data, "data/dummy_df.fst"),
  times = 10
)

summary(compare_write_binary, unit = "relative")

# Reading binary formats
compare_read_binary <- microbenchmark(
  read_rds = readr::read_rds("data/dummy_df.rds"),
  read_parquet = arrow::read_parquet("data/dummy_df.parquet"),
  read_fst = fst::read_fst("data/dummy_df.fst"),
  times = 10
)

summary(compare_read_binary, unit = "relative")

# 2 Data manipulation ---------------------------------------------------------

# Create a larger dataset with more complex grouping structure
create_bigger_dataset <- function(data, size = 5e6) {
  # repeat data until size is achieved
  nrow_data <- nrow(data)
  data <- data[rep(seq_len(nrow_data), length.out = size), ]
  # turn into a data table
  setDT(data)
  return(data)
}

big_data <- create_bigger_dataset(data = ghg_ems)

summarize_dt <- function() {
  big_data[, mean(Electricity, na.rm = TRUE), by = Country]
}

# 2. The dplyr way
summarize_dplyr <- function() {
  big_data |>
    group_by(Country) |>
    summarize(mean_e = mean(Electricity, na.rm = TRUE))
}

# 3. The collapse way
summarize_collapse <- function() {
  big_data |>
    fgroup_by(Country) |>
    fsummarise(mean_e = fmean(Electricity))
}

# 4. The Arrow way
arrow_tbl <- arrow_table(big_data, as_data_frame = FALSE)
summarize_arrow <- function() {
  # Convert to Arrow Table

  # Perform aggregation using Arrow's compute engine
  arrow_tbl |>
    group_by(Country) |>
    summarize(mean_e = mean(Electricity, na.rm = TRUE)) |>
    collect()
}

# Update benchmark to include Arrow
microbenchmark(
  dplyr = summarize_dplyr(),
  data_table = summarize_dt(),
  collapse = summarize_collapse(),
  arrow = summarize_arrow(),
  times = 10
)
