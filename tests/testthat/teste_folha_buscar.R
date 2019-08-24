context("folha_buscar")

inicio_mes <- Sys.Date() %>%
  format(format = "%d/%m/%Y") %>%
  stringr::str_replace("^\\d{1,2}", "01")

test_that("Resposta tem formato esperado", {
  expect_silent(busca <- folha_buscar("recessao", inicio_mes))

  expect_true(all(c("tbl_df", "data.frame") %in% class(busca)))
  expect_identical(length(busca), 5L)
  nomes <- c("secao", "manchete", "resumo", "hora", "link")
  expect_identical(names(busca), nomes)
})

test_that("Restricoes dos argumentos funcionam", {
  expect_true(TRUE)
})

