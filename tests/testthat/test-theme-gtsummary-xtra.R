test_that("theme_gtsummary_xtra validates set_theme argument", {
  expect_error(
    theme_gtsummary_xtra(set_theme = "yes"),
    "Assertion on 'set_theme' failed"
  )
  expect_error(
    theme_gtsummary_xtra(set_theme = NA),
    "Assertion on 'set_theme' failed"
  )
})

test_that("theme_gtsummary_xtra returns a valid gtsummary theme list", {
  withr::defer(gtsummary::reset_gtsummary_theme())
  gtsummary::reset_gtsummary_theme()

  lst <- theme_gtsummary_xtra(set_theme = FALSE)

  expect_type(lst, "list")
  expect_identical(lst[["pkgwide-str:theme_name"]], "xtra")
  expect_identical(gtsummary::get_gtsummary_theme(), list())
  expect_no_warning(
    suppressMessages(gtsummary::check_gtsummary_theme(lst))
  )

  suppressMessages(theme_gtsummary_xtra(set_theme = TRUE))
  expect_identical(
    gtsummary::get_gtsummary_theme()[["pkgwide-str:theme_name"]],
    "xtra"
  )
})

test_that("theme_gtsummary_xtra configures tbl_summary defaults and tests", {
  withr::defer(gtsummary::reset_gtsummary_theme())
  suppressMessages(theme_gtsummary_xtra())

  df <- data.frame(
    group2 = factor(rep(c("A", "B"), each = 10)),
    group3 = factor(rep(c("X", "Y", "Z"), length.out = 20)),
    short_score = rep(1:5, 4),
    binary_var = rep(c("No", "Yes"), 10)
  )

  tbl <- gtsummary::tbl_summary(
    df,
    by = "group2",
    include = c("short_score", "binary_var")
  ) |>
    gtsummary::add_p()

  # Numeric variable with <10 unique values remains continuous
  expect_identical(tbl$inputs$type[["short_score"]], "continuous")
  # Dichotomous variable is expanded to categorical (both levels shown)
  expect_identical(tbl$inputs$type[["binary_var"]], "categorical")
  expect_identical(
    tbl$table_body$label[tbl$table_body$variable == "binary_var"],
    c("binary_var", "No", "Yes")
  )
  # Mean (SD) with 1 decimal place
  expect_match(
    tbl$table_body$stat_1[tbl$table_body$variable == "short_score"],
    "^[0-9]+\\.[0-9] \\([0-9]+\\.[0-9]\\)$"
  )
  # Count (0 decimals) and percentage (1 decimal)
  expect_match(
    tbl$table_body$stat_1[
      tbl$table_body$variable == "binary_var" & tbl$table_body$label == "Yes"
    ],
    "^[0-9]+ \\([0-9]+\\.[0-9]%\\)$"
  )
  # Default 2-group continuous test is t.test
  expect_identical(
    tbl$table_body$test_name[tbl$table_body$variable == "short_score"],
    "t.test"
  )

  # Default 3-group continuous test is oneway.test
  tbl3 <- gtsummary::tbl_summary(
    df,
    by = "group3",
    include = "short_score"
  ) |>
    gtsummary::add_p()
  expect_identical(
    tbl3$table_body$test_name[tbl3$table_body$variable == "short_score"],
    "oneway.test"
  )
})

test_that("pre_conversion bolds labels by default and respects remove_bold()", {
  withr::defer(gtsummary::reset_gtsummary_theme())
  suppressMessages(theme_gtsummary_xtra())

  df <- data.frame(
    score1 = 1:10,
    score2 = 11:20
  )

  # Default: both continuous variable labels are bolded upon conversion
  ft_default <- gtsummary::tbl_summary(df) |>
    gtsummary::as_flex_table()
  expect_true(ft_default$body$styles$text$bold$data[1, "label"])
  expect_true(ft_default$body$styles$text$bold$data[2, "label"])

  # Overridden with remove_bold() and selective modify_bold()
  ft_custom <- gtsummary::tbl_summary(df) |>
    gtsummary::remove_bold(columns = "label") |>
    gtsummary::modify_bold(columns = "label", rows = variable == "score1") |>
    gtsummary::as_flex_table()
  expect_true(ft_custom$body$styles$text$bold$data[1, "label"])
  expect_false(ft_custom$body$styles$text$bold$data[2, "label"])

  # Flextable Word property repeat_headers is set to FALSE
  expect_false(ft_default$properties$opts_word$repeat_headers)
})

test_that("theme_gtsummary_xtra merges estimate and CI columns", {
  skip_if_not_installed("broom.helpers")
  withr::defer(gtsummary::reset_gtsummary_theme())
  suppressMessages(theme_gtsummary_xtra())

  mod <- stats::lm(mpg ~ wt + cyl, data = mtcars)
  tbl_reg <- gtsummary::tbl_regression(mod)

  expect_true("estimate" %in% tbl_reg$table_styling$cols_merge$column)
  expect_identical(
    tbl_reg$table_styling$cols_merge$pattern[
      tbl_reg$table_styling$cols_merge$column == "estimate"
    ],
    "{estimate} ({conf.low}, {conf.high})"
  )
  expect_match(
    tbl_reg$table_styling$header$label[
      tbl_reg$table_styling$header$column == "estimate"
    ],
    "\\*\\*\\(95% CI\\)\\*\\*$"
  )

  df_diff <- data.frame(
    trt = factor(rep(c("A", "B"), each = 15)),
    val = c(1:15, 6:20)
  )
  tbl_diff <- gtsummary::tbl_summary(df_diff, by = "trt") |>
    gtsummary::add_difference()

  expect_true("estimate" %in% tbl_diff$table_styling$cols_merge$column)
  expect_identical(
    tbl_diff$table_styling$cols_merge$pattern[
      tbl_diff$table_styling$cols_merge$column == "estimate"
    ],
    "{estimate} ({conf.low}, {conf.high})"
  )
})
