test_that("docx_add_img works", {
  # Create a temporary image
  img <- tempfile(fileext = ".png")
  png(img, width = 4, height = 3, units = "in", res = 72)
  plot(1:10)
  dev.off()

  doc <- officer::read_docx()
  result <- docx_add_img(doc, src = img, width = 4, height = 3)

  expect_s3_class(result, "rdocx")

  # Verify the document can be saved without error
  out <- tempfile(fileext = ".docx")
  expect_no_error(print(result, target = out))
  expect_true(file.exists(out))
})

test_that("captions and numbering are placed on a new line and kept together", {
  img <- tempfile(fileext = ".png")
  grDevices::png(img, width = 400, height = 300)
  plot(1:10)
  grDevices::dev.off()

  for (caption_pos in c("above", "below")) {
    for (content in c("caption", "number", "both")) {
      doc <- docx_add_img(
        officer::read_docx(),
        src = img,
        width = 2,
        height = 1.5,
        caption = if (content != "number") "Example caption" else NULL,
        autonum = if (content != "caption") officer::run_autonum() else NULL,
        caption_pos = caption_pos
      )

      body <- xml2::xml_find_first(officer::docx_body_xml(doc), "w:body")
      paragraphs <- xml2::xml_find_all(body, "w:p")
      figure <- paragraphs[[1]]
      expect_length(xml2::xml_find_all(figure, "w:pPr/w:keepLines"), 1L)
      expect_length(paragraphs, 2L)
      expect_equal(xml2::xml_text(paragraphs[[2]]), "")
      expect_length(
        xml2::xml_find_all(paragraphs[[2]], "w:pPr/w:keepLines"),
        0L
      )

      breaks <- xml2::xml_find_all(figure, "w:r/w:br")
      expect_length(breaks, 1L)
      expect_equal(xml2::xml_attr(breaks, "type"), "textWrapping")

      runs <- xml2::xml_find_all(figure, "w:r")
      n_runs <- length(runs)
      if (caption_pos == "below") {
        expect_length(xml2::xml_find_all(runs[[1]], "w:drawing"), 1L)
        expect_length(xml2::xml_find_all(runs[[2]], "w:br"), 1L)
      } else {
        expect_length(xml2::xml_find_all(runs[[n_runs - 1L]], "w:br"), 1L)
        expect_length(xml2::xml_find_all(runs[[n_runs]], "w:drawing"), 1L)
      }
    }
  }
})

test_that("images without captions or numbering have no line break", {
  img <- tempfile(fileext = ".png")
  grDevices::png(img, width = 400, height = 300)
  plot(1:10)
  grDevices::dev.off()

  for (caption_pos in c("above", "below")) {
    doc <- docx_add_img(
      officer::read_docx(),
      src = img,
      width = 2,
      height = 1.5,
      caption_pos = caption_pos
    )

    expect_length(
      xml2::xml_find_all(officer::docx_body_xml(doc), "//w:br"),
      0L
    )
    expect_length(
      xml2::xml_find_all(officer::docx_body_xml(doc), "//w:keepLines"),
      0L
    )
  }
})

test_that("tall images are scaled down with room for the caption and spacing", {
  img <- tempfile(fileext = ".png")
  grDevices::png(img, width = 400, height = 1400)
  plot(1:10)
  grDevices::dev.off()

  base_doc <- officer::read_docx()
  dims <- officer::docx_dim(base_doc)
  page_avail_height <- dims$page[["height"]] -
    dims$margins[["top"]] -
    dims$margins[["bottom"]]

  doc_uncaptioned <- docx_add_img(base_doc, src = img, width = 4, height = 14)
  ext_uncaptioned <- xml2::xml_find_first(
    officer::docx_body_xml(doc_uncaptioned),
    "//wp:extent"
  )
  height_uncaptioned <- as.numeric(xml2::xml_attr(ext_uncaptioned, "cy")) /
    914400
  expect_equal(height_uncaptioned, page_avail_height - 0.20, tolerance = 1e-3)

  doc_captioned <- docx_add_img(
    officer::read_docx(),
    src = img,
    width = 4,
    height = 14,
    caption = "Tall plot caption"
  )
  ext_captioned <- xml2::xml_find_first(
    officer::docx_body_xml(doc_captioned),
    "//wp:extent"
  )
  height_captioned <- as.numeric(xml2::xml_attr(ext_captioned, "cy")) / 914400
  expect_equal(height_captioned, page_avail_height - 0.60, tolerance = 1e-3)
})
