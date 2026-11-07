#' Set the xtra gtsummary theme
#'
#' Applies a custom [gtsummary][gtsummary::gtsummary-package] theme tailored for
#' publication-ready tables.
#'
#' The theme configures the following defaults:
#' * **Package-wide:**
#'   * Sets the theme name to `"xtra"`.
#'   * Rounds large p-values to 2 decimal places via
#'     `gtsummary::label_style_pvalue(digits = 2)`.
#'   * Automatically bolds variable labels before conversion with
#'     [gtsummary::bold_labels()]. Because this rule is placed before any
#'     table-specific formatting instructions, it can be overridden in a
#'     pipeline with [gtsummary::remove_bold()].
#' * **Flextable output ([gtsummary::as_flex_table()]):**
#'   * Disables repeating header rows across page breaks in Word documents
#'     (`opts_word = list(repeat_headers = FALSE)`).
#' * **Summary tables ([gtsummary::tbl_summary()]):**
#'   * Disables automatic conversion of numeric variables with few unique values
#'     to categorical (`"assign_summary_type-arg:cat_threshold" = 0L`), so
#'     numeric scores remain continuous unless explicitly typed otherwise.
#'   * Displays all levels of dichotomous variables
#'     (`all_dichotomous() ~ "categorical"`).
#'   * Summarizes continuous variables with `"{mean} ({sd})"` (rounded to 1
#'     decimal place) and categorical variables with `"{n} ({p}%)"` (counts as
#'     integers and percentages rounded to 1 decimal place).
#'   * Sets default continuous tests in [gtsummary::add_p()] to t-test
#'     (`"t.test"` / `"svy.t.test"`) and one-way ANOVA (`"oneway.test"`),
#'     matching [gtsummary::theme_gtsummary_mean_sd()].
#' * **Regression and difference tables:**
#'   * In [gtsummary::tbl_regression()] and [gtsummary::tbl_uvregression()],
#'     rounds regression coefficients and confidence interval bounds to 2
#'     decimal places via `gtsummary::label_style_number(digits = 2)`.
#'   * In [gtsummary::tbl_regression()], [gtsummary::tbl_uvregression()], and
#'     [gtsummary::add_difference()], merges the estimate and confidence
#'     interval columns into a single column formatted as
#'     `"{estimate} ({conf.low}, {conf.high})"` and updates the column header
#'     accordingly.
#'
#' Use [gtsummary::reset_gtsummary_theme()] to restore the default settings.
#'
#' @param set_theme Logical indicating whether to set the theme via
#'   [gtsummary::set_gtsummary_theme()]. Default is `TRUE`. When `FALSE`, the
#'   named list of theme elements is returned invisibly without activating the
#'   theme.
#' @return A named list of `gtsummary` theme elements (returned invisibly).
#' @seealso [Available gtsummary themes][gtsummary::theme_gtsummary],
#'   [gtsummary::set_gtsummary_theme()], [gtsummary::reset_gtsummary_theme()]
#' @export
#'
#' @examples
#' theme_gtsummary_xtra()
#'
#' gtsummary::tbl_summary(
#'   gtsummary::trial,
#'   by = "trt",
#'   include = c("age", "grade", "response")
#' ) |>
#'   gtsummary::as_flex_table()
#'
#' gtsummary::reset_gtsummary_theme()
theme_gtsummary_xtra <- function(set_theme = TRUE) {
  checkmate::assert_flag(set_theme, .var.name = "set_theme")

  lst_theme <- list(
    # Package-wide -------------------------------------------------------------
    "pkgwide-str:theme_name" = "xtra",
    "pkgwide-fn:pvalue_fun" = gtsummary::label_style_pvalue(digits = 2),
    "pkgwide-fun:pre_conversion" = function(x) {
      # Place bold_labels() before existing user text_format rules so that
      # calls to remove_bold() in the user's pipeline take precedence.
      user_text_format <- x$table_styling$text_format
      # Temporarily empty text_format while keeping its column structure so
      # bold_labels() writes only its own rule, then re-append user rules after.
      x$table_styling$text_format <- user_text_format[0, ]
      x <- gtsummary::bold_labels(x)
      x$table_styling$text_format <- dplyr::bind_rows(
        x$table_styling$text_format,
        user_text_format
      )
      x
    },

    # Flextable output ---------------------------------------------------------
    "as_flex_table-lst:addl_cmds" = list(
      # Insert after "valign" (the final step of gtsummary::as_flex_table())
      # so this command runs at the end of the flextable pipeline.
      valign = list(
        rlang::expr(
          flextable::set_table_properties(
            opts_word = list(repeat_headers = FALSE)
          )
        )
      )
    ),

    # Summary tables -----------------------------------------------------------
    "assign_summary_type-arg:cat_threshold" = 0L,
    "tbl_summary-arg:type" = list(
      gtsummary::all_dichotomous() ~ "categorical"
    ),
    "tbl_summary-arg:statistic" = list(
      gtsummary::all_continuous() ~ "{mean} ({sd})",
      gtsummary::all_categorical() ~ "{n} ({p}%)"
    ),
    "tbl_summary-arg:digits" = list(
      gtsummary::all_continuous() ~ c(1, 1),
      gtsummary::all_categorical() ~ c(0, 1)
    ),
    # Default continuous tests in add_p(), matching
    # gtsummary::theme_gtsummary_mean_sd().
    "add_p.tbl_summary-attr:test.continuous_by2" = "t.test",
    "add_p.tbl_summary-attr:test.continuous" = "oneway.test",
    "add_p.tbl_svysummary-attr:test.continuous" = "svy.t.test",

    # Regression and difference tables -----------------------------------------
    "tbl_regression-arg:estimate_fun" = gtsummary::label_style_number(
      digits = 2
    ),
    # Merge estimate and CI columns, adapted from
    # gtsummary::theme_gtsummary_journal("jama") with ", " instead of " to ".
    "add_difference-fn:addnl-fn-to-run" = function(x) {
      tryCatch(
        {
          new_header_text <- paste0(
            x$table_styling$header |>
              dplyr::filter(.data$column == "estimate") |>
              dplyr::pull("label"),
            " **(**",
            x$table_styling$header |>
              dplyr::filter(.data$column == "conf.low") |>
              dplyr::pull("label"),
            "**)**"
          )

          x |>
            gtsummary::modify_column_merge(
              rows = !!rlang::expr(
                .data$variable %in%
                  !!x$table_body$variable &
                  !is.na(.data$estimate)
              ),
              pattern = "{estimate} ({conf.low}, {conf.high})"
            ) |>
            gtsummary::modify_header(estimate = new_header_text)
        },
        error = function(e) x
      )
    },
    "tbl_regression-fn:addnl-fn-to-run" = function(x) {
      tryCatch(
        {
          new_header_text <- paste0(
            x$table_styling$header |>
              dplyr::filter(.data$column == "estimate") |>
              dplyr::pull("label"),
            " **(",
            gtsummary::style_number(x$inputs$conf.level, scale = 100),
            "% CI)**"
          )

          x |>
            gtsummary::modify_column_merge(
              rows = !!rlang::expr(
                .data$variable %in%
                  !!x$table_body$variable &
                  !is.na(.data$estimate) &
                  !.data$reference_row %in% TRUE
              ),
              pattern = "{estimate} ({conf.low}, {conf.high})"
            ) |>
            gtsummary::modify_header(estimate = new_header_text)
        },
        error = function(e) x
      )
    }
  )

  if (isTRUE(set_theme)) {
    gtsummary::set_gtsummary_theme(lst_theme)
  }
  invisible(lst_theme)
}
