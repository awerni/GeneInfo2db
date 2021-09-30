getDrive <- function() {
  con <- getPostgresqlConnection()
  
  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename) %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  # -------------------------
  
  gene_effect_long <- getFileData('gene_dep_scores@drive')
  
  gene_effect_long2 <- gene_effect_long %>%
    as.data.frame() %>%
    rename(gene = X1) %>%
    #tibble::rownames_to_column("celllinename") %>%
    tidyr::pivot_longer(!gene, names_to = "celllinename", values_to = "d2") %>%
    dplyr::mutate(geneid = gsub(".* \\(", "(", gene)) %>%
    dplyr::select(-gene) %>%
    dplyr::mutate(geneid = gsub("(\\(|\\))", "", geneid)) %>%
    dplyr::filter(!is.na(geneid) & !is.na(d2)) %>%
    dplyr::mutate(geneid = lapply(str_split(geneid, "&"), as.integer)) %>%
    tidyr::unnest(geneid)
  
  ensg <- get_gene_translation(unique(gene_effect_long2$geneid))
  
  gene_effect_long2 <- gene_effect_long2 %>%
    dplyr::inner_join(ensg, by = "geneid") %>%
    dplyr::select(celllinename, ensg, d2) %>%
    dplyr::mutate(depletionscreen = "Drive") %>%
    dplyr::filter(celllinename %in% cellline$celllinename) %>%
    dplyr::distinct(celllinename, ensg, .keep_all = TRUE)
  
  depletion_screen <- tibble::tribble(
    ~depletionscreen, ~depletionscreendescription,
    "Drive", "Novartis Drive siRNA Screen with Demeter2 score"
  )
  
  list(cellline.depletionscreen = depletion_screen,
       cellline.processeddepletionscore = gene_effect_long2)
}