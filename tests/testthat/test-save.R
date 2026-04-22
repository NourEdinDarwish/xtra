test_that("save_plot works", {
  tmp <- tempfile(fileext = ".png")
  result <- save_plot(
    function() plot(1:10), tmp,
    width = 5, height = 4
  )

  expect_true(file.exists(tmp))
  expect_type(result, "list")
  expect_equal(unname(result$width), 5)
  expect_equal(unname(result$height), 4)
  expect_equal(result$units, "in")
})
