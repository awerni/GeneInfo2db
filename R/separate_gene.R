separate_gene <- function(x) {

  # -- requires more memory, slower --
  #x %>% tidyr::separate("gene", c("symbol", "geneid"), sep = " ") %>%
  #  dplyr::mutate(geneid = as.numeric(gsub("(\\(|\\))", "", geneid)))

  res <- stringi::stri_split_fixed(x$gene, pattern = " ", simplify = TRUE)

  x %>%
    dplyr::mutate(symbol = res[,1], geneid = res[,2]) %>%
    dplyr::mutate(geneid = as.numeric(gsub("(\\(|\\))", "", geneid))) %>%
    dplyr::select(-gene)
}
