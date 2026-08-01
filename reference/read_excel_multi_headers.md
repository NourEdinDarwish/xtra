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

  `start_row,start_col`

  :   Optional numeric values specifying the first row or column to
      begin data discovery.

  `row_names`

  :   Logical; if TRUE, uses the first column of the selection as row
      names.

  `skip_hidden_rows,skip_hidden_cols`

  :   Logical; if TRUE, excludes rows or columns marked as hidden in the
      worksheet metadata.

  `rows,cols`

  :   Optional numeric vectors specifying the exact indices to read.

  `detect_dates`

  :   Logical; if TRUE, identifies date and datetime styles for
      conversion.

  `na`

  :   A character vector or a named list (e.g.,
      `list(strings = "", numbers = -99)`) defining values to treat as
      `NA`.

  `dims`

  :   A character string defining the range. Supports wildcards (e.g.,
      "A1:++" or "A-:+5").

  `show_formula`

  :   Logical; if TRUE, returns the formula strings instead of
      calculated values.

  `named_region`

  :   A character string referring to a defined name or spreadsheet
      Table.

  `keep_attributes`

  :   Logical; if TRUE, attaches metadata such as the internal type
      table (tt) and types as attributes to the output.

  `show_hyperlinks`

  :   Logical; if TRUE, replaces cell values with their underlying
      hyperlink targets.

  `apply_numfmts`

  :   Logical; if TRUE, applies spreadsheet number formatting and
      returns strings.

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
