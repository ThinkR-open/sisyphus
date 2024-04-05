.sisyphus <- new.env()

#' Run & Stop Sisyphus
#'
#' @export
#' @rdname sisyphus
#'
#' @importFrom later later destroy_loop
#' @importFrom testthat test_local
#'
#' @param check_fun Function to run when a file is edited
#' @param delay Delay between checks
#' @param files_to_watch Files to watch for changes
#' @param home Home directory from where to get R & tests files
#'
#' @return Used for side effect
#'
sisyphus_run <- function(
  check_fun = testthat::test_local,
  delay = 1,
  files_to_watch = sisyphus::sisyphus_get_r_and_tests(),
  files_to_ignore = sisyphus::sisyphus_get_testthat_snaps()
) {
  .sisyphus$loop <- later::create_loop()
  .sisyphus$check_fun <- check_fun
  .sisyphus$check_delay <- delay
  .sisyphus$files_to_watch <- setdiff(
    files_to_watch,
    files_to_ignore
  )

  later(
    last_edit_func,
    delay = .sisyphus$check_delay,
    .sisyphus$loop
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
sisyphus_change_files_to_watch <- function(files_to_watch) {
  .sisyphus$files_to_watch <- files_to_watch
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
    .sisyphus$files_to_watch
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

  later::later(
    last_edit_func,
    delay = .sisyphus$check_delay,
    .sisyphus$loop
  )
}
