test_that("read_excel_multi_headers works", {
  library(openxlsx2)

  # Build a simple workbook: merged "Demographics" over A1:B1, sub-headers in
  # row 2
  wb <- wb_workbook()$
    add_worksheet("Sheet1")$
    add_data(x = "Demographics", dims = "A1")$
    merge_cells(dims = "A1:B1")$
    add_data(x = "Name", dims = "A2")$
    add_data(x = "Age", dims = "B2")$
    add_data(x = "Alice", dims = "A3")$
    add_data(x = 30, dims = "B3")

  tmp <- tempfile(fileext = ".xlsx")
  wb$save(tmp)

  result <- read_excel_multi_headers(tmp, n_headers = 2)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true(all(c("Demographics_Name", "Demographics_Age") %in% names(result))) # nolint
  expect_equal(result$Demographics_Name, "Alice")
})
