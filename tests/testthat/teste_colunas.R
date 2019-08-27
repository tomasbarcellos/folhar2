context("colunas")

test_that("Funciona com vários tipos de entrada", {
  fernanda <- listar_textos("Fernanda Torres")
  fernanda2 <- listar_textos("FernandaTorres")
  fernanda3 <- listar_textos("fernandatorres")

  expect_identical(fernanda, fernanda2)
  expect_identical(fernanda, fernanda3)
})

test_that("Textos são listados como se espera", {
  denise <- listar_textos("Denise fraga")

  expect_length(denise, 10L)
  expect_identical(unique(denise$kicker), "Denise Fraga")
  expect_true(all(grepl(x = denise$url, "/colunas/")))
})

