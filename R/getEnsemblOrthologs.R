getEnsemblOrthologs <- function(db_compara, species_name, ortholog_species_name) {

  httr::set_config(httr::config(ssl_verifypeer = FALSE))
  #ensembl <- biomaRt::useEnsembl(biomart = "genes")
  ensembl <- biomaRt::useMart("ensembl")
  ensembl <- biomaRt::useDataset("hsapiens_gene_ensembl", mart = ensembl)

  biomaRt::listDatasets(ensembl)
  biomaRt::listFilters(ensembl)
  biomaRt::listAttributes(ensembl)

  a <- biomaRt::getBM(attributes = c("ensembl_gene_id", "mmusculus_homolog_ensembl_gene"), mart = ensembl)

  affyids <- c("202763_at", "209310_s_at", "207500_at")
  biomaRt::getBM(attributes = c("affy_hg_u133_plus_2", "hgnc_symbol", "chromosome_name", "start_position",
                       "end_position", "band"), filters = "affy_hg_u133_plus_2", values = affyids, mart = ensembl)

  conM <- getEnsemblDBConnection(db_compara)

  dbDisconnect(conM)
}
