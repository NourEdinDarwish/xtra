#' Merge headers in flextables created from gtsummary objects
#'
#' Vertically extends visible header cells through contiguous blank padding
#' cells immediately above them when the resulting merged area is rectangular.
#' Ordinary column labels and spanning headers are treated equally.
#'
#' This function is intended primarily for `flextable` objects produced by
#' [gtsummary::as_flex_table()], which uses `" "` (a single space) for missing
#' spanning-header cells. A cell containing exactly `" "` is therefore treated
#' as structural padding. Call this function immediately after conversion and
#' before applying additional header styling.
#'
#' Existing horizontal blank spans are split only where required for a
#' vertical merge. Header content is never crossed, and cells that are already
#' merged vertically are left unchanged.
#'
#' @param x A `flextable` object, typically produced by
#'   [gtsummary::as_flex_table()].
#' @return The modified `flextable` object.
#' @export
#'
#' @examplesIf (identical(Sys.getenv("NOT_CRAN"), "true") || identical(Sys.getenv("IN_PKGDOWN"), "true")) && requireNamespace("gtsummary", quietly = TRUE)
#' gtsummary::tbl_summary(
#'   gtsummary::trial,
#'   by = "trt",
#'   include = c("age", "marker")
#' ) |>
#'   gtsummary::modify_spanning_header(
#'     gtsummary::all_stat_cols() ~ "**Treatment Received**"
#'   ) |>
#'   gtsummary::as_flex_table() |>
#'   merge_headers()
merge_headers <- function(x) {
  if (!inherits(x, "flextable")) {
    cli::cli_abort("{.arg x} must be a {.cls flextable} object.")
  }

  header <- x$header$dataset
  n_header <- nrow(header)
  n_columns <- ncol(header)

  if (n_header < 2L) {
    return(x)
  }

  horizontal_spans <- x$header$spans$rows
  vertical_spans <- x$header$spans$columns
  merge_map <- matrix(NA_integer_, nrow = n_header, ncol = n_columns)
  merge_ops <- list()
  merge_id <- 0L

  # Identify all safe rectangles from the original, unmodified header grid.
  for (i in rev(seq_len(n_header))) {
    for (j in seq_len(n_columns)) {
      # Only visible anchors containing real header content can claim padding.
      if (
        horizontal_spans[i, j] < 1L ||
          vertical_spans[i, j] != 1L ||
          identical(header[i, j], " ")
      ) {
        next
      }

      columns <- seq.int(j, length.out = horizontal_spans[i, j])
      start <- i

      while (
        start > 1L &&
          all(header[start - 1L, columns, drop = TRUE] %in% " ") &&
          all(vertical_spans[start - 1L, columns, drop = TRUE] == 1L)
      ) {
        start <- start - 1L
      }

      if (start == i) {
        next
      }

      merge_id <- merge_id + 1L
      merge_map[seq.int(start, i - 1L), columns] <- merge_id
      merge_ops[[merge_id]] <- list(
        source_row = i,
        start_row = start,
        columns = columns
      )
    }
  }

  if (length(merge_ops) == 0L) {
    return(x)
  }

  # Split blank horizontal spans only along the new rectangle boundaries.
  affected_rows <- which(rowSums(!is.na(merge_map)) > 0L)
  for (i in affected_rows) {
    anchors <- which(horizontal_spans[i, ] > 0L)
    original_groups <- rep(
      seq_along(anchors),
      times = horizontal_spans[i, anchors]
    )

    keys <- paste0("original-", original_groups)
    to_merge <- !is.na(merge_map[i, ])
    keys[to_merge] <- paste0("merge-", merge_map[i, to_merge])

    runs <- rle(keys)
    starts <- cumsum(runs$lengths) - runs$lengths + 1L
    rebuilt_spans <- integer(n_columns)
    rebuilt_spans[starts] <- runs$lengths

    x$header$spans$rows[i, ] <- rebuilt_spans
  }

  # Move each cell's rich content to its new anchor, then merge its rectangle.
  for (op in merge_ops) {
    source_row <- op$source_row
    start_row <- op$start_row
    columns <- op$columns
    anchor <- columns[1]

    x$header$dataset[start_row, columns] <- header[source_row, columns]
    x$header$content$data[start_row, anchor] <-
      x$header$content$data[source_row, anchor]

    x <- flextable::merge_at(
      x,
      i = seq.int(start_row, source_row),
      j = columns,
      part = "header"
    )
  }

  x
}
