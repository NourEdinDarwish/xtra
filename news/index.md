# Changelog

## xtra (development version)

- New
  [`read_excel_multi_headers()`](https://nouredindarwish.github.io/xtra/reference/read_excel_multi_headers.md)
  reads Excel files (.xlsx, .xlsm, .xlsb) where multiple header rows
  (often with merged cells) need to be collapsed into a single row of
  column names. Supports tidy-select sheet selection and automatic type
  guessing.

- New
  [`save_plot()`](https://nouredindarwish.github.io/xtra/reference/save_plot.md)
  saves any R plot (ggplot, grid, or base R wrapped in a function) to a
  file. Adapted from
  [`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html),
  with broader support for arbitrary plotting calls.

- New
  [`docx_add_img()`](https://nouredindarwish.github.io/xtra/reference/docx_add_img.md)
  adds an image to a Word document with optional captioning and
  auto-numbering. Large images are automatically scaled down to fit
  within the page margins.

- New
  [`theme_gtsummary_xtra()`](https://nouredindarwish.github.io/xtra/reference/theme_gtsummary_xtra.md)
  sets a custom theme for gtsummary tables (2-digit p-values and
  regression estimates, bold labels that respect `remove_bold()`,
  continuous summary type for numeric variables with few unique values,
  showing all levels of dichotomous variables, Mean (SD) summary
  statistics with t-test and ANOVA defaults in `add_p()`, merged
  estimate and CI columns, and non-repeating Word headers).

- New
  [`merge_headers()`](https://nouredindarwish.github.io/xtra/reference/merge_headers.md)
  vertically extends header cells through contiguous single-space
  padding rows in flextables created from gtsummary objects. The cells
  are merged only when the resulting area is rectangular.
