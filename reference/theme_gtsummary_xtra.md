# Set the xtra gtsummary theme

Applies a custom
[gtsummary](https://www.danieldsjoberg.com/gtsummary/reference/gtsummary-package.html)
theme tailored for publication-ready tables.

## Usage

``` r
theme_gtsummary_xtra(set_theme = TRUE)
```

## Arguments

- set_theme:

  Logical indicating whether to set the theme via
  [`gtsummary::set_gtsummary_theme()`](https://www.danieldsjoberg.com/gtsummary/reference/set_gtsummary_theme.html).
  Default is `TRUE`. When `FALSE`, the named list of theme elements is
  returned invisibly without activating the theme.

## Value

A named list of `gtsummary` theme elements (returned invisibly).

## Details

The theme configures the following defaults:

- **Package-wide:**

  - Sets the theme name to `"xtra"`.

  - Rounds large p-values to 2 decimal places via
    `gtsummary::label_style_pvalue(digits = 2)`.

  - Automatically bolds variable labels before conversion with
    [`gtsummary::bold_labels()`](https://www.danieldsjoberg.com/gtsummary/reference/bold_italicize_labels_levels.html).
    Because this rule is placed before any table-specific formatting
    instructions, it can be overridden in a pipeline with
    [`gtsummary::remove_bold()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_bold_italic.html).

- **Flextable output
  ([`gtsummary::as_flex_table()`](https://www.danieldsjoberg.com/gtsummary/reference/as_flex_table.html)):**

  - Disables repeating header rows across page breaks in Word documents
    (`opts_word = list(repeat_headers = FALSE)`).

- **Summary tables
  ([`gtsummary::tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)):**

  - Disables automatic conversion of numeric variables with few unique
    values to categorical
    (`"assign_summary_type-arg:cat_threshold" = 0L`), so numeric scores
    remain continuous unless explicitly typed otherwise.

  - Displays all levels of dichotomous variables
    (`all_dichotomous() ~ "categorical"`).

  - Summarizes continuous variables with `"{mean} ({sd})"` (rounded to 1
    decimal place) and categorical variables with `"{n} ({p}%)"` (counts
    as integers and percentages rounded to 1 decimal place).

  - Sets default continuous tests in
    [`gtsummary::add_p()`](https://www.danieldsjoberg.com/gtsummary/reference/add_p.html)
    to t-test (`"t.test"` / `"svy.t.test"`) and one-way ANOVA
    (`"oneway.test"`), matching
    [`gtsummary::theme_gtsummary_mean_sd()`](https://www.danieldsjoberg.com/gtsummary/reference/theme_gtsummary.html).

- **Regression and difference tables:**

  - In
    [`gtsummary::tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html)
    and
    [`gtsummary::tbl_uvregression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_uvregression.html),
    rounds regression coefficients and confidence interval bounds to 2
    decimal places via `gtsummary::label_style_number(digits = 2)`.

  - In
    [`gtsummary::tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html),
    [`gtsummary::tbl_uvregression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_uvregression.html),
    and
    [`gtsummary::add_difference()`](https://www.danieldsjoberg.com/gtsummary/reference/add_difference.html),
    merges the estimate and confidence interval columns into a single
    column formatted as `"{estimate} ({conf.low}, {conf.high})"` and
    updates the column header accordingly.

Use
[`gtsummary::reset_gtsummary_theme()`](https://www.danieldsjoberg.com/gtsummary/reference/set_gtsummary_theme.html)
to restore the default settings.

## See also

[Available gtsummary
themes](https://www.danieldsjoberg.com/gtsummary/reference/theme_gtsummary.html),
[`gtsummary::set_gtsummary_theme()`](https://www.danieldsjoberg.com/gtsummary/reference/set_gtsummary_theme.html),
[`gtsummary::reset_gtsummary_theme()`](https://www.danieldsjoberg.com/gtsummary/reference/set_gtsummary_theme.html)

## Examples

``` r
theme_gtsummary_xtra()
#> Setting theme "xtra"

gtsummary::tbl_summary(
  gtsummary::trial,
  by = "trt",
  include = c("age", "grade", "response")
) |>
  gtsummary::as_flex_table()


.cl-d8bad469{}.cl-8a796ab5{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-5430bca3{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-56775354{font-family:'DejaVu Sans';font-size:6.6pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;vertical-align:super;}.cl-f4afa9ce{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:2pt;padding-top:2pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-df282d82{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:2pt;padding-top:2pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-c6655fef{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-03fa5271{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-d04581b7{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:15pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-6477613b{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-6d80541d{width:1.57in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(0, 0, 0, 1.00);border-top: 1pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-04f437cb{width:1.133in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(0, 0, 0, 1.00);border-top: 1pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-38f4ca36{width:1.57in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b89163bd{width:1.133in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-9c32db08{width:1.57in;background-color:transparent;vertical-align: top;border-bottom: 1pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2aca0a87{width:1.133in;background-color:transparent;vertical-align: top;border-bottom: 1pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-a8d093db{width:1.57in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(255, 255, 255, 0.00);border-top: 0 solid rgba(255, 255, 255, 0.00);border-left: 0 solid rgba(255, 255, 255, 0.00);border-right: 0 solid rgba(255, 255, 255, 0.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-be2390de{width:1.133in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(255, 255, 255, 0.00);border-top: 0 solid rgba(255, 255, 255, 0.00);border-left: 0 solid rgba(255, 255, 255, 0.00);border-right: 0 solid rgba(255, 255, 255, 0.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Characteristic
```
