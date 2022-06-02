getEntrezGene2EnsemblGene <- function(db_info, species_name) {

  db <- db_info %>%
    dplyr::filter(species == species_name) %>%
    as.list()

  conM <- getEnsemblDBConnection(db$database)

  sql <- paste0(
    "SELECT g.stable_id AS ensg, dbprimary_acc AS geneid ",
    "FROM gene g, seq_region sr, xref xr, object_xref oxr, external_db edb ",
    "WHERE sr.seq_region_id = g.seq_region_id ",
    "AND xr.xref_id = oxr.xref_id AND xr.external_db_id = edb.external_db_id ",
    "AND g.gene_id = oxr.ensembl_id ",
    "AND g.gene_id = oxr.ensembl_id AND db_name = 'EntrezGene' ",
    "AND g.stable_id like 'ENS%'"
  )

  res <- DBI::dbSendQuery(conM, sql)
  eg2eg <- DBI::dbFetch(res)
  DBI::dbClearResult(res)
  DBI::dbDisconnect(conM)
  return(eg2eg)
}
