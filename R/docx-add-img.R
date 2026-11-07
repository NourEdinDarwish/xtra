#' Add an image to a Word document
#'
#' Adds an image to a Word document with optional captioning and auto-numbering.
#' Images larger than the page margins are automatically scaled down to fit
#' within the available page space while preserving their aspect ratio.
#'
#' When a caption or auto-numbering is provided, it is placed on a new line
#' within the same paragraph as the image, with Word's "Keep lines together"
#' option enabled so they are not split across a page break. An empty paragraph
#' is also added after each figure for spacing.
#'
#' @param x An `rdocx` object, created with [officer::read_docx()].
#' @param src Path to the image file.
#' @param width,height Image size in units expressed by the `units` argument.
#' @param units One of the following units in which the `width` and `height`
#'   arguments are expressed: `"in"`, `"cm"`, `"mm"` or `"px"`. Default is
#'   `"in"`.
#' @param dpi Plot resolution. Only used when `units = "px"`. Default is 300.
#' @param caption The text to display as the image caption. If `NULL` (default),
#'   no caption is added.
#' @param caption_pos Position of the caption relative to the image. One of
#'   `"below"` or `"above"`. Default is `"below"`.
#' @param autonum Auto-numbering (e.g., to automatically generate "Figure 1: "),
#'   created with [officer::run_autonum()]. If `NULL` (default), no
#'   auto-numbering is added.
#' @param fp_t Text formatting properties for the caption text, created with
#'   [officer::fp_text()]. Note that this does not affect the styling of the
#'   auto-numbering (use the `prop` argument in [officer::run_autonum()] for
#'   that).
#' @param fp_p Paragraph formatting properties applied to the entire paragraph
#'   (image, caption, and auto-numbering), created with [officer::fp_par()].
#' @return The modified `rdocx` object.
#' @examples
#' library(officer)
#'
#' # Create a temporary image
#' img <- tempfile(fileext = ".png")
#' png(img, width = 4, height = 3, units = "in", res = 72)
#' plot(1:10, main = "Example Plot")
#' dev.off()
#'
#' doc <- read_docx()
#' doc <- docx_add_img(doc, src = img, width = 4, height = 3)
#' print(doc, target = tempfile(fileext = ".docx"))
#' @export
docx_add_img <- function(
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
) {
  # 1. Validation
  # Core Arguments
  checkmate::assert_class(x, "rdocx", .var.name = "x")
  checkmate::assert_string(src, min.chars = 1, .var.name = "src")
  checkmate::assert_file_exists(src, .var.name = "src")

  # Dimensions & Units
  checkmate::assert_number(
    width,
    lower = 0,
    finite = TRUE,
    .var.name = "width"
  )
  checkmate::assert_number(
    height,
    lower = 0,
    finite = TRUE,
    .var.name = "height"
  )
  units <- rlang::arg_match0(units, c("in", "cm", "mm", "px"))
  checkmate::assert_number(dpi, lower = 0, finite = TRUE, .var.name = "dpi")

  # Caption & Content
  checkmate::assert_string(caption, null.ok = TRUE, .var.name = "caption")
  caption_pos <- rlang::arg_match0(caption_pos, c("below", "above"))

  # Styling & Metadata Objects
  checkmate::assert_class(
    autonum,
    "run_autonum",
    null.ok = TRUE,
    .var.name = "autonum"
  )
  checkmate::assert_class(fp_t, "fp_text", null.ok = TRUE, .var.name = "fp_t")
  checkmate::assert_class(fp_p, "fp_par", null.ok = TRUE, .var.name = "fp_p")

  # 2. Convert to inches
  dim <- to_inches(c(width, height), units, dpi = dpi)
  width_in <- dim[1]
  height_in <- dim[2]

  # 3. Get document dimensions and calculate available space
  doc_dims <- officer::docx_dim(x)

  # Available width = Page Width - Left - Right
  avail_width <- doc_dims$page[["width"]] -
    doc_dims$margins[["left"]] -
    doc_dims$margins[["right"]]

  # Available height = Page Height - Top - Bottom
  # Note: header/footer in $margins are distances from edge to header/footer,
  # but margin.top/margin.bottom determine the main text body limits.
  #
  # Subtract space for the trailing empty paragraph (~0.20 in), plus a 2-line
  # caption (~0.40 in) when a caption or numbering is present. Otherwise, an
  # image scaled to the full page height leaves no room on the page for its
  # caption or the empty paragraph, pushing them onto the next page (which can
  # separate the caption from the image or create a blank page between two
  # tall images).
  avail_height <- doc_dims$page[["height"]] -
    doc_dims$margins[["top"]] -
    doc_dims$margins[["bottom"]] -
    0.20 -
    if (!is.null(caption) || !is.null(autonum)) 0.40 else 0

  # 4. Auto-resize if necessary (maintaining aspect ratio)
  # Calculate scaling factor to fit within available dimensions
  # We use min(1, ...) to ensure we only scale down, not up
  width_ratio <- avail_width / width_in
  height_ratio <- avail_height / height_in

  scale_factor <- min(width_ratio, height_ratio, 1)

  width_in <- width_in * scale_factor
  height_in <- height_in * scale_factor

  # 5. Prepare Content
  # Create caption content
  caption_chunk <- if (!is.null(caption)) {
    officer::ftext(caption, prop = fp_t)
  } else {
    NULL
  }

  # Create image content
  img_chunk <- officer::external_img(
    src = src,
    width = width_in,
    height = height_in
  )

  # 6. Assemble Paragraph
  # Start the caption on its own line within the same paragraph.
  caption_break <- if (!is.null(caption) || !is.null(autonum)) {
    officer::run_linebreak()
  } else {
    NULL
  }

  raw_chunks <- if (caption_pos == "above") {
    list(autonum, caption_chunk, caption_break, img_chunk)
  } else {
    list(img_chunk, caption_break, autonum, caption_chunk)
  }

  # We use discard() instead of compact() because compact() removes empty
  # lists by default, including the one returned by run_linebreak().
  # We only want to remove NULLs.
  chunks <- purrr::discard(raw_chunks, is.null)

  fpar_obj <- if (is.null(fp_p)) {
    rlang::inject(officer::fpar(!!!chunks))
  } else {
    rlang::inject(officer::fpar(!!!chunks, fp_p = !!fp_p))
  }

  # 7. Add to Document
  x <- officer::body_add_fpar(x, fpar_obj)

  # The image and caption are in the same paragraph, separated by a line break
  # (<w:br/>). By default, Word still allows a page break between lines of the
  # same paragraph, which can put the image at the bottom of one page and the
  # caption at the top of the next.
  #
  # Word's "Keep lines together" setting (<w:keepLines/> inside <w:pPr>) keeps
  # all lines of a paragraph on the same page when the whole paragraph fits.
  # Unlike keep_with_next (<w:keepNext/>), officer::fp_par() has no option for
  # <w:keepLines/>, so we add it directly to the paragraph's <w:pPr> XML node.
  if (!is.null(caption) || !is.null(autonum)) {
    paragraph_properties <- xml2::xml_find_first(
      officer::docx_current_block_xml(x),
      "w:pPr"
    )
    xml2::xml_add_child(paragraph_properties, "w:keepLines")
  }

  # Add an empty paragraph after the figure for spacing
  x <- officer::body_add_par(x, "")

  x
}
