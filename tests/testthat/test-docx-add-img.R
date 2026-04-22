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
