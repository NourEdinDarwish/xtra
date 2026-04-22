# Read an Excel file with multiple header rows

Reads one or more sheets from an Excel file (.xlsx, .xlsm, .xlsb) with
multiple header rows (often involving merged cells). These rows are
automatically collapsed to form a single row of column names.

## Usage

``` r
read_excel_multi_headers(
  file,
  sheets = 1,
  n_headers = 1,
  sep = "_",
  skip_empty_rows = TRUE,
  skip_empty_cols = TRUE,
  simplify = TRUE,
  ...
)
```

## Arguments

- file:

  A path to an existing .xlsx, .xlsm, or .xlsb file.

- sheets:

  \<[`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html)\>
  Sheets to read. Defaults to `1` (the first sheet).

- n_headers:

  Number of header rows at the top of the sheet to combine into a single
  row of column names. Defaults to `1`.

- sep:

  String used to separate the text from each header cell when combining
  them into a single column name. Defaults to `"_"` (e.g.,
  `"Header1_Header2"`).

- skip_empty_rows, skip_empty_cols:

  If `TRUE` (the default), rows or columns that contain only missing
  values are removed.

- simplify:

  If `TRUE` (the default) and only one sheet is read, return a single
  data frame. If `FALSE`, always return a named list of data frames.

- ...:

  Arguments passed on to
  [`openxlsx2::wb_to_df`](https://janmarvin.github.io/openxlsx2/reference/wb_to_df.html)

  `start_row`

  :   first row to begin looking for data.

  `start_col`

  :   first column to begin looking for data.

  `row_names`

  :   If `TRUE`, the first col of data will be used as row names.

  `skip_hidden_rows`

  :   If `TRUE`, hidden rows are skipped.

  `skip_hidden_cols`

  :   If `TRUE`, hidden columns are skipped.

  `rows`

  :   A numeric vector specifying which rows in the xlsx file to read.
      If `NULL`, all rows are read.

  `cols`

  :   A numeric vector specifying which columns in the xlsx file to
      read. If `NULL`, all columns are read.

  `detect_dates`

  :   If `TRUE`, attempt to recognize dates and perform conversion.

  `na`

  :   Defines values to be treated as NA. Can be a character vector of
      strings or a named list: list(strings = ..., numbers = ...). Blank
      cells are always converted to `NA`.

  `dims`

  :   Character string of type "A1:B2" as optional dimensions to be
      imported.

  `show_formula`

  :   If `TRUE`, the underlying spreadsheet formulas are shown.

  `named_region`

  :   Character string with a `named_region` (defined name or table). If
      no sheet is selected, the first appearance will be selected. See
      [`wb_get_named_regions()`](https://janmarvin.github.io/openxlsx2/reference/named_region-wb.html)

  `keep_attributes`

  :   If `TRUE` additional attributes are returned. (These are used
      internally to define a cell type.)

  `show_hyperlinks`

  :   If `TRUE` instead of the displayed text, hyperlink targets are
      shown.

  `apply_numfmts`

  :   If `TRUE` numeric formats are applied if detected.

## Value

A data frame (if one sheet and `simplify = TRUE`) or a named list of
data frames.

## Details

This function processes each requested sheet individually. For each
column in a sheet, the header rows are combined vertically into a single
name, separated by `sep`. During this process, the value of each merged
cell is propagated to every cell in the merged range, missing or
whitespace-only cell values are ignored, and consecutive duplicate
values are deduplicated. For example, a column where `"Demographics"` is
merged across two cells, followed by a blank cell and an `"Age"` cell,
cleanly collapses into `"Demographics_Age"` (rather than
`"Demographics_Demographics__Age"`). Finally, column names are repaired
to ensure uniqueness, and data types are automatically guessed after
import. All merged cells in the sheet (not just headers) are unmerged,
with each cell in the range receiving the original merged value.

Header collapsing is performed after empty rows and columns are removed
(when `skip_empty_rows` or `skip_empty_cols` is `TRUE`), so `n_headers`
refers to the first rows of the resulting sheet.

## Examples

``` r
library(openxlsx2)
#> 
#> Attaching package: ‘openxlsx2’
#> The following object is masked from ‘package:officer’:
#> 
#>     read_xlsx

# Create a workbook with a merged header spanning two columns
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

read_excel_multi_headers(tmp, n_headers = 2)
#>   Demographics_Name Demographics_Age
#> 1             Alice               30
```
