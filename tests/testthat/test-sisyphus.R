test_that("sisyphus_run works", {
  testthat::with_mocked_bindings(
    later = list,
    {
      res <- sisyphus_run()
      expect_equal(
        res$func,
        last_edit_func
      )
      expect_equal(
        res$delay,
        .sisyphus$check_delay
      )
      expect_equal(
        res$loop,
        .sisyphus$loop
      )
    }
  )
})

test_that("sisyphus_stop works", {
  testthat::with_mocked_bindings(
    later = list,
    {
      res <- sisyphus_run()
      expect_true(
        later::exists_loop(
          sisyphus:::.sisyphus$loop
        )
      )
      sisyphus_stop()
      expect_false(
        later::exists_loop(
          sisyphus:::.sisyphus$loop
        )
      )
    }
  )
})

test_that("sisyphus_get_r_and_tests works", {
  test_dir <- file.path(tempdir(), "test_sisyphus")
  unlink(test_dir, recursive = TRUE, force = TRUE)
  dir.create(file.path(test_dir, "R"), recursive = TRUE)
  expect_equal(
    sisyphus_get_r_and_tests(home = test_dir),
    character(0)
  )
  file.create(file.path(test_dir, "R", "test.R"))
  expect_equal(
    basename(
      sisyphus_get_r_and_tests(home = test_dir)
    ),
    "test.R"
  )
  unlink(test_dir, recursive = TRUE, force = TRUE)
})

test_that("sisyphus_get_r_and_tests works", {
  test_dir <- file.path(tempdir(), "test_sisyphus")
  unlink(test_dir, recursive = TRUE, force = TRUE)
  dir.create(
    file.path(
      test_dir,
      "tests",
      "testthat",
      "_snaps"
    ),
    recursive = TRUE
  )
  file.create(
    file.path(
      test_dir,
      "tests",
      "testthat",
      "_snaps",
      "punkrockers"
    )
  )
  expect_equal(
    basename(
      sisyphus_get_testthat_snaps(home = test_dir)
    ),
    "punkrockers"
  )
})

test_that("sisyphus_change_delay works", {
  sisyphus_change_delay(0.1)
  expect_equal(
    .sisyphus$check_delay,
    0.1
  )
})

test_that("sisyphus_change_check_fun works", {
  sisyphus_change_check_fun(function() {
    1
  })
  expect_equal(
    .sisyphus$check_fun(),
    1
  )
})

test_that("sisyphus_change_fun_files_to_watch works", {
  sisyphus_change_fun_files_to_watch(\(){
    "test.R"
  })
  expect_equal(
    .sisyphus$fun_files_to_watch(),
    "test.R"
  )
})

test_that("sisyphus_change_fun_files_to_ignore works", {
  sisyphus_change_fun_files_to_ignore(\(){
    "test.R"
  })
  expect_equal(
    .sisyphus$fun_files_to_ignore(),
    "test.R"
  )
})


test_that("last_edit_func works", {
  testthat::with_mocked_bindings(
    later = list,
    {
      test_dir <- file.path(tempdir(), "test_sisyphus")
      unlink(test_dir, recursive = TRUE, force = TRUE)
      dir.create(file.path(test_dir, "R"), recursive = TRUE)
      ftw <- file.path(test_dir, "R", "test.R")
      file.create(ftw)
      sisyphus_run(
        fun_files_to_watch = \(){
          ftw
        },
        check_fun = function() {
          1
        }
      )
      res <- last_edit_func()
      expect_equal(
        res$func,
        last_edit_func
      )
      expect_equal(
        res$delay,
        .sisyphus$check_delay
      )
      expect_equal(
        res$loop,
        .sisyphus$loop
      )
      write("punkrockers", ftw)
      res <- last_edit_func()
      expect_equal(
        res$func,
        last_edit_func
      )
      expect_equal(
        res$delay,
        .sisyphus$check_delay
      )
      expect_equal(
        res$loop,
        .sisyphus$loop
      )
    }
  )
})
