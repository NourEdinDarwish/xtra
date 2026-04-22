# xtra (development version)

* New `read_excel_multi_headers()` reads Excel files (.xlsx, .xlsm, .xlsb)
  where multiple header rows (often with merged cells) need to be collapsed
  into a single row of column names. Supports tidy-select sheet selection and
  automatic type guessing.

* New `save_plot()` saves any R plot (ggplot, grid, or base R wrapped in a
  function) to a file. Adapted from `ggplot2::ggsave()`, with broader support
  for arbitrary plotting calls.

* New `docx_add_img()` adds an image to a Word document with optional
  captioning and auto-numbering. Large images are automatically scaled down to
  fit within the page margins.
