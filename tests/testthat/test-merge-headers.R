make_complex_header <- function() {
  data <- data.frame(
    num = c(0.1111, 2.2220, 33.3300),
    currency = c(49.95, 17.95, 1.39),
    char = c("apricot", "banana", "coconut"),
    fctr = c("one", "two", "three"),
    date = c("2015-01-15", "2015-02-15", "2015-03-15"),
    time = c("13:35", "14:40", "15:45"),
    datetime = c("2018-01-01", "2018-02-02", "2018-03-03"),
    row = c("row_1", "row_2", "row_3"),
    group = rep("grp_a", 3)
  )

  flextable::flextable(data) |>
    flextable::add_header_row(
      values = c(" ", "Text Values", " "),
      colwidths = c(2, 2, 5)
    ) |>
    flextable::add_header_row(
      values = c("Numeric Values", "Text, Dates, Times, Datetimes", " "),
      colwidths = c(2, 5, 2)
    ) |>
    flextable::add_header_row(
      values = c(" ", "Date and Time Columns", " "),
      colwidths = c(4, 3, 2)
    )
}

test_that("merge_headers creates maximal safe rectangles", {
  result <- make_complex_header() |>
    merge_headers()

  expect_equal(
    unname(result$header$spans$rows),
    rbind(
      c(2, 0, 2, 0, 3, 0, 0, 1, 1),
      c(2, 0, 5, 0, 0, 0, 0, 1, 1),
      c(1, 1, 2, 0, 1, 1, 1, 1, 1),
      rep(1, 9)
    )
  )
  expect_equal(
    unname(result$header$spans$columns),
    rbind(
      c(2, 2, 1, 1, 1, 1, 1, 4, 4),
      c(0, 0, 1, 1, 1, 1, 1, 0, 0),
      c(2, 2, 1, 1, 2, 2, 2, 0, 0),
      c(0, 0, 1, 1, 0, 0, 0, 0, 0)
    )
  )
})

test_that("partial blank areas are not merged", {
  result <- make_complex_header() |>
    merge_headers()

  # This five-column spanner cannot move upward because the row above it
  # contains the three-column Date and Time spanner.
  expect_equal(result$header$spans$columns[2, 3:7], rep(1, 5))

  # The unused remainder above char and fctr stays horizontally merged.
  expect_equal(result$header$spans$rows[1, 3:4], c(2, 0))
})

test_that("rich header content moves to the new anchor", {
  table <- flextable::flextable(data.frame(a = 1, b = 2)) |>
    flextable::compose(
      i = 1,
      j = 1,
      part = "header",
      value = flextable::as_paragraph(flextable::as_b("Alpha"))
    ) |>
    flextable::add_header_row(
      values = c(" ", "Group"),
      colwidths = c(1, 1)
    )

  original_content <- table$header$content$data[2, 1]
  result <- merge_headers(table)

  expect_identical(result$header$content$data[1, 1], original_content)
  expect_equal(result$header$spans$columns[, 1], c(2, 0))
})

test_that("merge_headers is idempotent", {
  once <- make_complex_header() |>
    merge_headers()
  twice <- once |>
    merge_headers()

  expect_identical(twice$header$dataset, once$header$dataset)
  expect_identical(twice$header$spans, once$header$spans)
})

test_that("existing vertical merges are left unchanged", {
  table <- flextable::flextable(data.frame(a = 1, b = 2)) |>
    flextable::set_header_labels(a = "Label", b = "Value") |>
    flextable::add_header_row(
      values = c("Label", "Group"),
      colwidths = c(1, 1)
    ) |>
    flextable::add_header_row(
      values = c(" ", "Top"),
      colwidths = c(1, 1)
    ) |>
    flextable::merge_v(j = 1, part = "header")

  expect_identical(merge_headers(table), table)
})

test_that("a single header row is unchanged", {
  table <- flextable::flextable(data.frame(a = 1, b = 2))

  expect_identical(merge_headers(table), table)
})

test_that("x must be a flextable", {
  expect_error(
    merge_headers(data.frame(a = 1)),
    "`x` must be a <flextable> object.",
    fixed = TRUE
  )
})

test_that("label headers span blank rows in flextables from gtsummary", {
  skip_if_not_installed("gtsummary")

  tbl1 <- gtsummary::tbl_summary(
    gtsummary::trial,
    by = "trt",
    include = "age"
  )
  tbl2 <- gtsummary::tbl_summary(
    gtsummary::trial,
    by = "trt",
    include = "marker"
  )
  table <- gtsummary::tbl_merge(list(tbl1, tbl2), quiet = TRUE) |>
    gtsummary::as_flex_table()

  result <- merge_headers(table)

  expect_equal(result$header$spans$columns[, 1], c(2, 0))
})
