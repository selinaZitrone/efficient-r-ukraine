library(tidyverse)
library(data.table)
library(arrow)

# If your data has many columns, it also helps to specify the column types to
# speed up the reading process.

# Path to wider data files
file_path_wider_csv <- "data/data_many_columns.csv"
file_path_wider_xlsx <- "data/data_many_columns.xlsx"

# Comprehensive benchmark for wide data with column specifications
# Careful: This takes a while to run!
compare_read_wide_colClasses <- microbenchmark(
  # Base R
  read.csv = read.csv(file_path_wider_csv),
  read.csv_colClasses = read.csv(
    file_path_wider_csv,
    colClasses = c(
      "character",
      "character",
      "character",
      "character",
      "character",
      rep("numeric", 25)
    )
  ),

  # readr
  read_csv = readr::read_csv(
    file_path_wider_csv,
    progress = FALSE,
    show_col_types = FALSE
  ),
  read_csv_colClasses = readr::read_csv(
    file_path_wider_csv,
    col_types = paste0(
      "ccccc", # id, date1, date2, text1, text2
      paste(rep("d", 25), collapse = "") # 25 numeric columns
    ),
    progress = FALSE,
    show_col_types = FALSE
  ),

  # data.table
  fread = data.table::fread(file_path_wider_csv, showProgress = FALSE),
  fread_colClasses = data.table::fread(
    file_path_wider_csv,
    colClasses = list(
      character = 1:5,
      numeric = 6:30
    ),
    showProgress = FALSE
  ),

  # arrow
  read_csv_arrow = arrow::read_csv_arrow(file_path_wider_csv),
  read_csv_arrow_colClasses = arrow::read_csv_arrow(
    file_path_wider_csv,
    col_types = schema(
      id = utf8(),
      date1 = utf8(),
      date2 = utf8(),
      text1 = utf8(),
      text2 = utf8(),
      .default = float64() # All remaining columns will be float64
    )
  ),

  # Excel
  read_excel = readxl::read_excel(file_path_wider_xlsx),
  read_excel_colClasses = readxl::read_excel(
    file_path_wider_xlsx,
    col_types = c(
      rep("text", 5),
      rep("numeric", 25)
    )
  ),

  times = 10
)

# Display results
autoplot(compare_read_wide_colClasses)
summary(compare_read_wide_colClasses, unit = "relative")


# Install stickr package if not already installed
library(stickr)

# Create directory if it doesn't exist
dir.create("img/stickr", recursive = TRUE, showWarnings = FALSE)

stickr::stickr_get("data.table", destfile = "img/stickr/data.table.png")


# List of packages to download stickers for
packages <- c(
  # Core packages
  "tictoc",
  "microbenchmark",
  "profvis",

  # Data manipulation
  "data.table",
  "dplyr",
  "collapse",

  # File I/O
  "readr",
  "readxl",
  "writexl",
  "arrow",
  "fst",

  # Parallelization
  "future",
  "future.apply",
  "doFuture",
  "foreach",
  "furrr",
  "parallel",

  # Performance optimization
  "Rcpp",
  "memoise"
)

# Function to safely download stickers
download_sticker <- function(pkg) {
  tryCatch(
    {
      cat("Downloading sticker for:", pkg, "\n")
      stickr::stickr_get(pkg, destfile = paste0("img/stickr/", pkg, ".png"))
      cat("Downloaded:", pkg, "\n")
    },
    error = function(e) {
      cat("Failed to download sticker for:", pkg, "\n")
      cat("Error:", conditionMessage(e), "\n\n")
    }
  )
}

# Download stickers for all packages
for (pkg in packages) {
  download_sticker(pkg)
  # Add a small delay to avoid overwhelming the server
  Sys.sleep(0.5)
}

# Additionally, check for stickers from specific organizations
orgs <- c("r-lib", "tidyverse", "rstudio")
for (org in orgs) {
  tryCatch(
    {
      cat("\nChecking for additional stickers from:", org, "\n")
      stickers <- stickr::stickr_list(org)
      cat("Found", length(stickers), "stickers from", org, "\n")

      # Download only those not already downloaded
      additional_stickers <- setdiff(stickers, packages)
      if (length(additional_stickers) > 0) {
        cat(
          "Downloading additional stickers:",
          paste(additional_stickers, collapse = ", "),
          "\n"
        )
        for (sticker in additional_stickers) {
          download_sticker(sticker)
          Sys.sleep(0.5)
        }
      }
    },
    error = function(e) {
      cat("Error checking organization:", org, "\n")
      cat("Error:", conditionMessage(e), "\n\n")
    }
  )
}

cat("\nSticker download complete! Files saved to img/stickr/\n")
