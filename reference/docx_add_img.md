# Add an image to a Word document

Adds an image to a Word document with optional captioning and
auto-numbering. Images larger than the page margins are automatically
scaled down to fit within the available page space while preserving
their aspect ratio.

## Usage

``` r
docx_add_img(
  x,
  src,
  width,
  height,
  units = c("in", "cm", "mm", "px"),
  dpi = 300,
  caption = NULL,
  caption_pos = c("below", "above"),
  autonum = NULL,
  fp_t = NULL,
  fp_p = NULL
)
```

## Arguments

- x:

  An `rdocx` object, created with
  [`officer::read_docx()`](https://davidgohel.github.io/officer/reference/read_docx.html).

- src:

  Path to the image file.

- width, height:

  Image size in units expressed by the `units` argument.

- units:

  One of the following units in which the `width` and `height` arguments
  are expressed: `"in"`, `"cm"`, `"mm"` or `"px"`. Default is `"in"`.

- dpi:

  Plot resolution. Only used when `units = "px"`. Default is 300.

- caption:

  The text to display as the image caption. If `NULL` (default), no
  caption is added.

- caption_pos:

  Position of the caption relative to the image. One of `"below"` or
  `"above"`. Default is `"below"`.

- autonum:

  Auto-numbering (e.g., to automatically generate "Figure 1: "), created
  with
  [`officer::run_autonum()`](https://davidgohel.github.io/officer/reference/run_autonum.html).
  If `NULL` (default), no auto-numbering is added.

- fp_t:

  Text formatting properties for the caption text, created with
  [`officer::fp_text()`](https://davidgohel.github.io/officer/reference/fp_text.html).
  Note that this does not affect the styling of the auto-numbering (use
  the `prop` argument in
  [`officer::run_autonum()`](https://davidgohel.github.io/officer/reference/run_autonum.html)
  for that).

- fp_p:

  Paragraph formatting properties applied to the entire paragraph
  (image, caption, and auto-numbering), created with
  [`officer::fp_par()`](https://davidgohel.github.io/officer/reference/fp_par.html).

## Value

The modified `rdocx` object.

## Examples

``` r
library(officer)

# Create a temporary image
img <- tempfile(fileext = ".png")
png(img, width = 4, height = 3, units = "in", res = 72)
plot(1:10, main = "Example Plot")
dev.off()
#> agg_record_19dc5147b22e 
#>                       2 

doc <- read_docx()
doc <- docx_add_img(doc, src = img, width = 4, height = 3)
print(doc, target = tempfile(fileext = ".docx"))
```
