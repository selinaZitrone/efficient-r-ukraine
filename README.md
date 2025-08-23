# Efficient R - Workshop for Ukraine

This repository contains materials for the "Efficient R" workshop.

## Workshop description

**Registration:** Register on the [official workshop website](https://sites.google.com/view/dariia-mykhailyshyna/main/r-workshops-for-ukraine)

**Date:** Thursday, August 28th, 18:00 - 20:00 CEST (Rome, Berlin, Paris timezone)

**Description:** Writing efficient R code is key to handling large datasets, reducing runtimes, and making your workflows more scalable. In this workshop, you'll learn practical strategies to find and fix performance issues and how to use packages that improve code speed and memory efficiency. The topics include:

- Profiling and benchmarking to find slow code and compare alternatives with `profvis` and `microbenchmark`
- Best practices to avoid common bottlenecks
- Efficient data analysis using packages like `data.table`, `collapse`, and `arrow`
- Parallelization with packages from the `futureverse`
- C++ integration to boost performance further with `Rcpp`

The session includes live demonstrations and code examples to follow during or after the workshop. Whether you're an experienced R user looking to optimize your code, or a beginner curious about writing more efficient scripts, this session offers insights and tools you can apply to your work.

## Preparation

You can follow the whole workshop without running the code examples yourself. But if
you want to try out the examples, you can prepare by following these steps:

1. Install R and RStudio. You can follow the installation guide [here](https://selinazitrone.github.io/intro-r-data-analysis/preparations.html)

2. Optional if you want to try out Rcpp for C++ integration: Install C++ compilers. You can follow the installation guide [here](https://teuder.github.io/rcpp4everyone_en/020_install.html)

3. Install the required R packages for following the code examples:

```r
# Performance measurement
install.packages(c("tictoc", "microbenchmark", "profvis"))

# Data manipulation and I/O
install.packages(c("tidyverse", "data.table", "collapse", "arrow", "fst"))

# Parallelization
install.packages(c("future", "future.apply", "doFuture", "foreach", "furrr"))

# C++ integration
install.packages("Rcpp")
```

4. Download the workshop materials from [this repository](https://github.com/selinaZitrone/efficient-r-ukraine)


## Repository Structure

- **Slides**: The main workshop content is available as:
  - [`slides.qmd`](slides.qmd) - Quarto source file
  - [`slides.pdf`](slides.pdf) - PDF version of the slides

- **R Scripts**: The [`R`](R) directory contains scripts with examples organized by topic:
  - `01_profiling_benchmarking.R` - Tools to measure code performance
  - `02_basic_principles.R` - Fundamental optimization principles
  - `03_efficient_data_analysis.R` - Fast data manipulation techniques
  - `04_Parallelization.R` - Running code in parallel
  - `05_rcpp.R` - Using C++ to speed up R code
  - `fibonacci.cpp` - Example C++ file used with Rcpp

- **Data**: The [`data`](data) directory contains various file formats used for benchmarking different data import/export methods.

- **Images**: The [`img`](img) folder contains images used in the slides.

## Required Packages

To run the example scripts, you'll need to install several R packages. You can install them with the following code:

```r
# Performance measurement
install.packages(c("tictoc", "microbenchmark", "profvis"))

# Data manipulation and I/O
install.packages(c("tidyverse", "data.table", "collapse", "arrow", "fst"))

# Parallelization
install.packages(c("future", "future.apply", "doFuture", "foreach", "furrr"))

# C++ integration
install.packages("Rcpp")
```

## Resources

### Books

- [Efficient R Programming](https://csgillespie.github.io/efficientR/) by Colin Gillespie and Robin Lovelace
- [Advanced R](https://adv-r.hadley.nz/) by Hadley Wickham

### R Packages for Efficient Programming

#### Performance Measurement
- [`profvis`](https://profvis.r-lib.org/) - Interactive visualizations for profiling R code
- [`microbenchmark`](https://cran.r-universe.dev/microbenchmark/doc/manual.html) - Precise timing of expression evaluation
- [`tictoc`](https://github.com/collectivemedia/tictoc?tab=readme-ov-file) - Timing functions for R

#### Data Manipulation
- [`data.table`](https://rdatatable.gitlab.io/data.table/) - Fast data manipulation with concise syntax
- [`collapse`](https://sebkrantz.github.io/collapse/) - Advanced and fast data transformation
- [`tidyverse`](https://www.tidyverse.org/) - Collection of packages for data science

#### Efficient I/O
- [`arrow`](https://arrow.apache.org/docs/r/) - Interface to Apache Arrow for fast data access
- [`fst`](https://www.fstpackage.org/) - Lightning fast serialization of data frames

#### Parallelization
- [futureverse Website](https://futureverse.org/) - Collection of packages for parallel and distributed processing
  - [`future`](https://future.futureverse.org/) - Unified parallel and distributed processing
  - [`future.apply`](https://future.apply.futureverse.org/) - Parallel apply functions
  - [`doFuture`](https://doFuture.futureverse.org/) - Foreach parallel adaptor for future
- [`furrr`](https://furrr.futureverse.org/) - Apply mapping functions in parallel

#### C++ Integration
- [`Rcpp`](https://www.rcpp.org/) - Seamless R and C++ integration

#### Others

There are so many other cool packages that I could not include in the workshop. Have a look if you are interested:

- [`memoise`](https://memoise.r-lib.org/) - Function result caching
- [`polars`](https://pola-rs.github.io/r-polars/) - Fast DataFrames powered by Rust
- [`dbplyr`](https://dbplyr.tidyverse.org/) - Database backend for dplyr
- [`dtplyr`](https://dtplyr.tidyverse.org/) - Data.table backend for dplyr
