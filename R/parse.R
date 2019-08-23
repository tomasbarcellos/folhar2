#' Buscar na folha
#'
#' @param termo termo buscado
#' @param inicio inicio do periodo da busca
#' @param fim fim do periodo da busca
#' @param media_espera media do tempo de espera entre requisicoes
#'
#' @return uma \link{\code{tibble}} com informacoes dos resultados da busca
#' @export
#'
#' @examples
#' folha_buscar("recessao")
folha_buscar <- function(termo, inicio = NULL, fim = NULL, media_espera = 1) {
  formar_url(termo, inicio = inicio, fim = fim) %>%
    adicionar_paginacao() %>%
    purrr::map_df(
      purrr::possibly(gentilmente(parse_busca, media_espera), Sys.sleep(3))
    )
}

#' Faz parse da busca
#'
#' @param link url de uma pagina da busca
#'
#' @return uma \link{\code{tibble}} com informacoes dos resultados da busca
#'
parse_busca <- function(link) {
  html <- xml2::read_html(link)

  secoes <- html %>%
    rvest::html_nodes("h3") %>%
    rvest::html_text()

  manchetes <- html %>%
    rvest::html_nodes("a > h2") %>%
    rvest::html_text() %>%
    stringr::str_squish()

  resumos <- html %>%
    rvest::html_nodes("a > p") %>%
    rvest::html_text() %>%
    stringr::str_squish()

  horas <- html %>%
    rvest::html_nodes("time") %>%
    rvest::html_text() %>%
    stringr::str_squish()

  links <- html %>%
    html_nodes("div.c-headline__content > a") %>%
    html_attr("href")

  tibble::tibble(
    secao = secoes, manchete = manchetes,
    resumo = resumos, hora = horas, link = links
  )
}

#' Roda gentilmente
#'
#' @param .f funcao a rodar
#' @param mean tempo medio de espera entre uma execucao e outra
#'
#' @return uma funcao que executa \code{.f} depois de um intervalo
#' aletorio com media \code{mean}
#'
#' @examples
#' media_gentil <- gentilmente(mean)
#' system.time(media_gentil(1:9))
gentilmente <- function(.f, mean = 1) {
  function(...) {
    Sys.sleep(abs(rnorm(1, mean = mean)))
    .f(...)
  }
}

#' Formar url com termo e periodo da busca
#'
#' @param termo termo buscado
#' @param inicio inicio do periodo da busca
#' @param fim fim do periodo da busca
#'
#' @return uma string com url da busca
#'
#' @examples
#' formar_url("recessao")
formar_url <- function(termo, inicio, fim) {
  if (is.null(inicio)) {
    inicio <- "01/01/1900"
  }

  if (is.null(fim)) {
    fim <- format(Sys.Date(), format = "%d/%m/%Y")
  }

  inicio <- stringr::str_replace_all(inicio, "/", "%2F")
  fim <- stringr::str_replace_all(fim, "/", "%2F")

  termo <- stringr::str_replace_all(termo, " ", "+")

  glue::glue(
    "https://search.folha.uol.com.br/?q={termo}",
    "&periodo=personalizado&sd={inicio}&ed={fim}",
    "&site=jornal"
  )
}

#' Adiciona paginacao a uma url
#'
#' @param url url da primeira pagina da busca gerada por
#' \link{\code{formar_url}}
#'
#' @return um vetor de strings com urls de cada pagina da busca
#'
adicionar_paginacao <- function(url) {
  seta_prox <- xml2::read_html(url) %>%
    rvest::html_node(".c-pagination__arrow > a")

  # Caso sem seta. sem resultados ou menos de 26
  if (length(seta_prox) == 0) return(url)

  n_resultados <- seta_prox %>%
    rvest::html_attr("href") %>%
    stringr::str_extract("(?<=results_count=)[0-9]+") %>%
    as.numeric()

  paginas <- seq(from = 1, to = n_resultados, by = 25)

  glue::glue("{url}&results_count={n_resultados}&sr={paginas}")
}

#' Pipe
#'
#' @importFrom magrittr %>%
#' @rdname pipe
#' @export
NULL
