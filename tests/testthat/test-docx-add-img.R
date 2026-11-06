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

test_that("captions and numbering are separated from images by a line break", {
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
      expect_length(paragraphs, 2L)
      expect_equal(xml2::xml_text(paragraphs[[2]]), "")

      breaks <- xml2::xml_find_all(figure, ".//w:br")
      expect_length(breaks, 1L)
      expect_equal(xml2::xml_attr(breaks, "type"), "textWrapping")

      following <- xml2::xml_find_all(
        figure,
        ".//w:br/parent::w:r/following-sibling::w:r//w:drawing"
      )
      expect_length(following, if (caption_pos == "above") 1L else 0L)

      if (content != "number") {
        caption_after <- xml2::xml_find_all(
          figure,
          ".//w:br/parent::w:r/following-sibling::w:r/w:t"
        )
        expect_equal(
          "Example caption" %in% xml2::xml_text(caption_after),
          caption_pos == "below"
        )
      }
      if (content != "caption") {
        number_after <- xml2::xml_find_all(
          figure,
          ".//w:br/parent::w:r/following-sibling::w:r/w:instrText"
        )
        expect_length(number_after, if (caption_pos == "below") 1L else 0L)
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
  }
})
