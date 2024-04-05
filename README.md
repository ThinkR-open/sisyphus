
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sisyphus

<!-- badges: start -->
<!-- badges: end -->

The goal of sisyphus is to …

## Installation

You can install the development version of sisyphus like so:

``` r
pak::pak("thinkr-open/sisyphus")
```

## Example

Run `testthat::test_local` every time you save a file in the `R/`
directory:

``` r
sisyphus::sisyphus_run()
```

By default, the function is configured this way:

- The function launched is `testthat::test_local()`

- The check for modification is done every 1 second

- The directory to watch is `R/`

You can change these settings by passing arguments to the function:

``` r
sisyphus::sisyphus_run(
  check_fun = devtools::check,
  delay = 2,
  files_to_watch = list.files(
    ".",
    recursive = TRUE,
    full.names = TRUE
  )
)
```

To stop the check, run `sisyphus_stop()`.

To change the config of the checks while the loop is running, you can
use `sisyphus_change_delay()`, `sisyphus_change_check_fun()`, and
`sisyphus_change_files_to_watch()`.

## Code of Conduct

Please note that the sisyphus project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
