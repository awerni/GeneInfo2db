getDrive <- function() {
  con <- getPostgresqlConnection()
  
  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename) %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  # -------------------------
  
  gene_effect_long <- getFileData('gene_effect@drive') %>%
    as.data.frame() %>%
    tibble::rownames_to_column("celllinename") %>%
    tidyr::pivot_longer(!celllinename, names_to = "gene", values_to = "d2") %>%
    dplyr::mutate(geneid = gsub(".* \\(", "(", gene)) %>%
    dplyr::select(-gene) %>%
    dplyr::mutate(geneid = gsub("(\\(|\\))", "", geneid)) %>%
    dplyr::filter(!is.na(geneid) & !is.na(d2)) %>%
    dplyr::mutate(geneid = lapply(str_split(geneid, "&"), as.integer)) %>%
    tidyr::unnest(geneid)
  
  gene_dependency_long <- getFileData("gene_dependency@drive") %>%
    as.data.frame() %>%
    tibble::rownames_to_column("celllinename") %>%
    tidyr::pivot_longer(!celllinename, names_to = "gene", values_to = "dep_prob") %>%
    dplyr::mutate(geneid = gsub(".* \\(", "(", gene)) %>%
    dplyr::select(-gene) %>%
    dplyr::mutate(geneid = gsub("(\\(|\\))", "", geneid)) %>%
    dplyr::filter(!is.na(geneid) & !is.na(dep_prob)) %>%
    dplyr::mutate(geneid = lapply(str_split(geneid, "&"), as.integer)) %>%
    tidyr::unnest(geneid) %>%
    dplyr::mutate(dep_prob = ifelse(dep_prob < 1e-45, 0, dep_prob))
  
  ensg <- get_gene_translation(unique(gene_effect_long$geneid))
  
  gene_effect_long2 <- gene_effect_long %>%
    dplyr::inner_join(gene_dependency_long, by = c("geneid", "celllinename")) %>%
    dplyr::inner_join(ensg, by = "geneid") %>%
    dplyr::select(celllinename, ensg, d2, dep_prob) %>%
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