separate_gene <- function(x) {
  res <- stringi::stri_split_fixed(x$gene, pattern = " ", simplify = TRUE)
  (x 
    %>% mutate(symbol = res[,1], geneid = res[,2]) 
    %>% dplyr::mutate(geneid = as.numeric(gsub("(\\(|\\))", "", geneid)))
    %>% select(-gene)
  )
}
