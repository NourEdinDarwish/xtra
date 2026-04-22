# Save a plot to a file

Adapted from
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html).
A general-purpose plot-saving function that works with any R plotting
system. Accepts `ggplot` objects, `grid` objects, or any plotting call
wrapped in a function. Unlike
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html),
which only supports `ggplot` and `grid` objects, `save_plot()` can
capture any plotting call (e.g., base R) by wrapping it in a function
(e.g., `function() plot(1:10)`).

## Usage

``` r
save_plot(
  plot,
  filename,
  device = NULL,
  path = NULL,
  width = NA,
  height = NA,
  units = c("in", "cm", "mm", "px"),
  dpi = 300,
  ...
)
```

## Arguments

- plot:

  Plot to save. A `ggplot` object, a `grid` object, or any plotting call
  (e.g., base R) wrapped in a function (e.g., `function() plot(1:10)`).

- filename:

  File name to create on disk.

- device:

  Device to use. Can either be a device function (e.g.
  [png](https://rdrr.io/r/grDevices/png.html)), or one of `"eps"`,
  `"ps"`, `"tex"` (pictex), `"pdf"`, `"jpeg"`, `"tiff"`, `"png"`,
  `"bmp"`, `"svg"` or `"wmf"` (Windows only). If `NULL` (default), the
  device is guessed based on the `filename` extension.

- path:

  Path of the directory to save plot to: `path` and `filename` are
  combined to create the fully qualified file name. Defaults to the
  working directory.

- width, height:

  Plot size in units expressed by the `units` argument. If not supplied,
  uses the size of the current graphics device.

- units:

  One of the following units in which the `width` and `height` arguments
  are expressed: `"in"`, `"cm"`, `"mm"` or `"px"`.

- dpi:

  Plot resolution.

- ...:

  Other arguments passed on to the graphics device function, as
  specified by `device`.

## Value

A named list (returned invisibly) with elements:

- `file`: Full file path.

- `width`: Plot width.

- `height`: Plot height.

- `units`: Unit of `width` and `height`.

- `dpi`: Plot resolution.

## See also

[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)

## Examples

``` r
tmp <- tempfile(fileext = ".png")
save_plot(function() plot(1:10), tmp, width = 5, height = 4)
```
