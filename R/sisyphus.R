.sisyphus <- new.env()

#' Watch files for changes and run a function when one or more are edited
#'
#' Run Sisyphus to check for changes in files and run a function when a file is edited.
#' - `sisyphus_run()` & `sisyphus_stop()` start and stop file watching
#' - `sisyphus_change_delay()`, `sisyphus_change_check_fun()`, `sisyphus_change_fun_files_to_watch()`, `sisyphus_change_fun_files_to_ignore()` change the delay between checks, the function to run when a file is edited, the function that returns the files to watch for changes, and the function that returns the files to ignore the changes, respectively.
#' - `sisyphus_get_r_and_tests()` returns a list of R and test files to watch for changes
#' - `sisyphus_get_testthat_snaps()` returns a list of testthat snapshot files to ignore
#'
#' @export
#' @rdname sisyphus
#'
#' @importFrom later later destroy_loop create_loop
#' @importFrom testthat test_local
#'
#' @param check_fun Function to run when a file is edited
#' @param delay Delay between checks
#' @param fun_files_to_watch Function that return a list of files to watch for changes
#' @param fun_files_to_ignore Function that return a list of files to ignore the changes
#' @param home Home directory from where to get R & tests files
#'
#' @return Used for side effect
#'
sisyphus_run <- function(
  check_fun = testthat::test_local,
  delay = 1,
  fun_files_to_watch = sisyphus::sisyphus_get_r_and_tests,
  fun_files_to_ignore = sisyphus::sisyphus_get_testthat_snaps
) {
  .sisyphus$loop <- create_loop()
  .sisyphus$check_fun <- check_fun
  .sisyphus$check_delay <- delay
  .sisyphus$fun_files_to_watch <- fun_files_to_watch
  .sisyphus$fun_files_to_ignore <- fun_files_to_ignore
  later(
    func = last_edit_func,
    delay = .sisyphus$check_delay,
    loop = .sisyphus$loop
  )
}

#' @export
#' @rdname sisyphus
sisyphus_stop <- function() {
  destroy_loop(.sisyphus$loop)
}

#' @export
#' @rdname sisyphus
sisyphus_change_delay <- function(delay) {
  .sisyphus$check_delay <- delay
}

#' @export
#' @rdname sisyphus
sisyphus_change_check_fun <- function(check_fun) {
  .sisyphus$check_fun <- check_fun
}

#' @export
#' @rdname sisyphus
sisyphus_change_fun_files_to_watch <- function(fun_files_to_watch) {
  .sisyphus$fun_files_to_watch <- fun_files_to_watch
}

#' @export
#' @rdname sisyphus
sisyphus_change_fun_files_to_ignore <- function(fun_files_to_ignore) {
  .sisyphus$fun_files_to_ignore <- fun_files_to_ignore
}

#' @export
#' @rdname sisyphus
sisyphus_get_r_and_tests <- function(
  home = getwd()) {
  c(
    list.files(
      path = file.path(
        home,
        "R"
      ),
      pattern = ".R$",
      full.names = TRUE
    ),
    list.files(
      path = file.path(
        home,
        "tests"
      ),
      recursive = TRUE,
      full.names = TRUE
    )
  )
}

#' @export
#' @rdname sisyphus
sisyphus_get_testthat_snaps <- function(
  home = getwd()) {
  list.files(
    path = file.path(
      home,
      "tests",
      "testthat",
      "_snaps"
    ),
    recursive = TRUE,
    full.names = TRUE
  )
}

last_edit_func <- function() {
  last_edit <- file.info(
    setdiff(
      .sisyphus$fun_files_to_watch(),
      .sisyphus$fun_files_to_ignore()
    )
  )
  last_editdf <- data.frame(
    file = row.names(last_edit),
    date = as.character(last_edit$mtime),
    size = last_edit$size
  )
  if (!is.null(.sisyphus$last_edit)) {
    if (!identical(.sisyphus$last_edit, last_editdf)) {
      try({
        .sisyphus$check_fun()
      })
    }
  }
  .sisyphus$last_edit <- last_editdf

  later(
    func = last_edit_func,
    delay = .sisyphus$check_delay,
    loop = .sisyphus$loop
  )
}
