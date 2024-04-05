test_that("sisyphus_get_r_and_tests works", {
  expect_equal(
    sisyphus_get_r_and_tests(home = tempdir()),
    character(0)
  )
})
