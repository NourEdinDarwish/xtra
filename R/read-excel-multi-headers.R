#' Read an Excel file with multiple header rows
#'
#' Reads one or more sheets from an Excel file (.xlsx, .xlsm, .xlsb) with
#' multiple header rows (often involving merged cells). These rows are
#' automatically collapsed to form a single row of column names.
#'
#' This function processes each requested sheet individually. For each column in
#' a sheet, the header rows are combined vertically into a single name,
#' separated by `sep`. During this process, the value of each merged cell is
#' propagated to every cell in the merged range, missing or whitespace-only cell
#' values are ignored, and consecutive duplicate values are deduplicated. For
#' example, a column where `"Demographics"` is merged across two cells, followed
#' by a blank cell and an `"Age"` cell, cleanly collapses into
#' `"Demographics_Age"` (rather than `"Demographics_Demographics__Age"`).
#' Finally, column names are repaired to ensure uniqueness, and data types are
#' automatically guessed after import. All merged cells in the sheet (not just
#' headers) are unmerged, with each cell in the range receiving the original
#' merged value.
#'
#' Header collapsing is performed after empty rows and columns are removed (when
#' `skip_empty_rows` or `skip_empty_cols` is `TRUE`), so `n_headers` refers to
#' the first rows of the resulting sheet.
#'
#' @param file A path to an existing .xlsx, .xlsm, or .xlsb file.
#' @param sheets <[`tidy-select`][dplyr::dplyr_tidy_select]> Sheets to read.
#'   Defaults to `1` (the first sheet).
#' @param n_headers Number of header rows at the top of the sheet to combine
#'   into a single row of column names. Defaults to `1`.
#' @param sep String used to separate the text from each header cell when
#'   combining them into a single column name. Defaults to `"_"` (e.g.,
#'   `"Header1_Header2"`).
#' @param skip_empty_rows,skip_empty_cols If `TRUE` (the default), rows or
#'   columns that contain only missing values are removed.
#' @param simplify If `TRUE` (the default) and only one sheet is read, return a
#'   single data frame. If `FALSE`, always return a named list of data frames.
#' @inheritDotParams openxlsx2::wb_to_df -sheet -col_names -convert -fill_merged_cells -types -check_names -skip_empty_rows -skip_empty_cols
#' @return A data frame (if one sheet and `simplify = TRUE`) or a named list of
#'   data frames.
#' @examples
#' library(openxlsx2)
#'
#' # Create a workbook with a merged header spanning two columns
#' wb <- wb_workbook()$
#'   add_worksheet("Sheet1")$
#'   add_data(x = "Demographics", dims = "A1")$
#'   merge_cells(dims = "A1:B1")$
#'   add_data(x = "Name", dims = "A2")$
#'   add_data(x = "Age", dims = "B2")$
#'   add_data(x = "Alice", dims = "A3")$
#'   add_data(x = 30, dims = "B3")
#'
#' tmp <- tempfile(fileext = ".xlsx")
#' wb$save(tmp)
#'
#' read_excel_multi_headers(tmp, n_headers = 2)
#' @export
read_excel_multi_headers <- function(
  file,
  sheets = 1,
  n_headers = 1,
  sep = "_",
  skip_empty_rows = TRUE,
  skip_empty_cols = TRUE,
  simplify = TRUE,
  ...
) {
  # 1. Argument Validation and Cleaning

  # Capture dots to inspect and filter them
  dots <- rlang::list2(...)

  # Check for arguments that are controlled internally
  blocked <- intersect(
    names(dots),
    c(
      "sheet",
      "col_names",
      "convert",
      "fill_merged_cells",
      "types",
      "check_names"
    )
  )

  if (length(blocked)) {
    cli::cli_warn(
      "{.arg {blocked}} {?is/are} ignored because
       {?it is/they are} controlled internally."
    )
    dots[blocked] <- NULL
  }

  # Strict type checks
  checkmate::assert_count(
    n_headers,
    positive = TRUE,
    .var.name = "n_headers"
  )
  checkmate::assert_string(sep, .var.name = "sep")

  # 2. Workbook Setup

  # Load workbook once. wb_load will throw an error if the file doesn't exist.
  wb <- openxlsx2::wb_load(file)
  all_sheet_names <- openxlsx2::wb_get_sheet_names(wb)

  # 3. Determine sheets to process using tidyselect

  # Prepare choice vector for tidyselect (named vector of indices)
  sheet_choices <- rlang::set_names(seq_along(all_sheet_names), all_sheet_names)

  # Evaluate selection
  selected_idx <- tidyselect::eval_select(
    rlang::enquo(sheets),
    data = sheet_choices
  )

  if (length(selected_idx) == 0) {
    cli::cli_abort("No sheets matched the selection criteria.")
  }

  sheets_to_process <- all_sheet_names[selected_idx]

  # 4. Processing Loop

  cleaned_data_list <- purrr::set_names(sheets_to_process) |>
    purrr::map(function(sheet_name) {
      # Use tryCatch to handle errors per-sheet without stopping the whole
      # process
      tryCatch(
        {
          # A. Read Raw Data
          # We use rlang::exec to pass the arguments.
          # We pass the 'dots' list using `!!!` (splice).
          # We DO NOT pass `...` here, because `...` contains the dirty/blocked
          # args.
          raw_df <- rlang::exec(
            openxlsx2::wb_to_df,
            file = wb,
            sheet = sheet_name,
            col_names = FALSE, # Hardcoded overrides
            convert = FALSE,
            fill_merged_cells = TRUE,
            skip_empty_rows = skip_empty_rows,
            skip_empty_cols = skip_empty_cols,
            !!!dots, # Cleaned user arguments
            .env = rlang::current_env()
          )

          if (is.null(raw_df)) {
            cli::cli_abort("Sheet is empty.")
          }

          # B. Check Bounds
          if (nrow(raw_df) <= n_headers) {
            cli::cli_abort(
              "Sheet has {nrow(raw_df)} row{?s} but {.arg n_headers}
               is set to {n_headers}."
            )
          }

          # C. Create Headers
          # Slice top N rows, trim whitespace, and collapse merged cells
          new_headers <- raw_df |>
            dplyr::slice(1:n_headers) |>
            dplyr::summarise(dplyr::across(dplyr::everything(), function(col) {
              col[is.na(col)] <- ""
              col <- trimws(col)
              unique_consecutive <- rle(col)$values
              final_parts <- unique_consecutive[unique_consecutive != ""]
              paste(final_parts, collapse = sep)
            })) |>
            unlist(use.names = FALSE)

          # Ensure headers are valid and unique (tidyverse-style name repair)
          new_headers <- vctrs::vec_as_names(
            new_headers,
            repair = "unique",
            quiet = TRUE
          )

          # D. Final Data Construction
          # Slice data body and convert types
          data_df <- raw_df |>
            dplyr::slice((n_headers + 1):dplyr::n()) |>
            purrr::set_names(new_headers)

          suppressMessages(readr::type_convert(data_df, na = character()))
        },
        error = function(e) {
          # Warn about the failure and return NULL
          cli::cli_warn(c(
            "!" = "Skipping sheet {.val {sheet_name}} due to error.",
            "i" = e$message
          ))
          NULL
        }
      )
    })

  # 5. Finalizing Results

  # Remove sheets that returned NULL (failed)
  cleaned_data_list <- purrr::compact(cleaned_data_list)

  # Check if all sheets failed
  if (length(cleaned_data_list) == 0) {
    cli::cli_abort("All selected sheets failed to import.")
  }

  # Return single data frame if only one sheet AND simplify is requested
  # Note: if user selected multiple sheets but only one succeeded, we still
  # respect simplify=TRUE which seems consistent.
  if (isTRUE(simplify) && length(cleaned_data_list) == 1) {
    cleaned_data_list[[1]]
  } else {
    cleaned_data_list
  }
}
