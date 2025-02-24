getCellline_CRISPR_screen_chronos <- function(
  screen_name,
  screen_desc,
  file_effect,
  file_dependency
) {

  con <- getPostgresqlConnection()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  |>
    dplyr::filter(species == "human") |>
    dplyr::select(celllinename, depmap) |>
    dplyr::collect()

  sql <- "SELECT count(*) FROM entrezgene2ensemblgene"
  n_genes <-  DBI::dbGetQuery(con, sql)

  RPostgres::dbDisconnect(con)

  # -----------

  logger::log_trace(paste(n_genes$count, "mappings for entrez gene to ensembl gene are available"))

  gene_effect_long_new <- getFileData(file_effect)

  if ("matrix" %in% class(gene_effect_long_new)) {
    gene_effect_long_new <- gene_effect_long_new  |>
      as.data.frame() |>
      tibble::rownames_to_column("depmap")
  } else {
    gene_effect_long_new <- gene_effect_long_new |>
      dplyr::rename(depmap = 1)
  }

  gene_effect_long_new <- gene_effect_long_new |>
    #tidyr::gather(key = "gene", value = "chronos", -depmap) |>
    tidyr::pivot_longer(cols = -depmap, names_to = "gene", values_to = "chronos") |>
    dplyr::inner_join(cellline, by = "depmap") |>
    dplyr::select(-depmap) |>
    separate_gene()

  ensg <- getEntrezGene2ENSG(geneid = unique(gene_effect_long_new$geneid))

  # ------------
  gene_dependency_long_new <- getFileData(file_dependency)

  if ("matrix" %in% class(gene_dependency_long_new)) {
    gene_dependency_long_new <- gene_dependency_long_new |>
      as.data.frame() |>
      tibble::rownames_to_column("depmap")
  } else {
    gene_dependency_long_new <- gene_dependency_long_new |>
      dplyr::rename(depmap = 1)
  }

  gene_dependency_long_new <- gene_dependency_long_new |>
    tidyr::pivot_longer(!depmap, names_to = "gene", values_to = "chronos_prob") |>
    dplyr::inner_join(cellline, by = "depmap") |>
    dplyr::select(-depmap) |>
    separate_gene() |>
    dplyr::mutate(chronos_prob = ifelse(chronos_prob < 1e-45, 0, chronos_prob))

  gene_effect_long <- gene_effect_long_new |>
    dplyr::inner_join(gene_dependency_long_new, by = c("symbol", "geneid", "celllinename")) |>
    dplyr::inner_join(ensg, by = "geneid") |>
    dplyr::select(celllinename, ensg, chronos, chronos_prob) |>
    dplyr::mutate(depletionscreen = screen_name) |>
    dplyr::distinct(celllinename, ensg, .keep_all = TRUE)

  depletion_screen <- tibble::tribble(
    ~depletionscreen, ~depletionscreendescription,
    screen_name, screen_desc
  )

  list(cellline.depletionscreen = depletion_screen,
       cellline.processeddepletionscore = gene_effect_long)

}
