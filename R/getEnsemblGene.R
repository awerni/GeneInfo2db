getEnsemblGene <- function(con, symbol_source) {
  # --- gene
  sql1 = paste0(
    "SELECT g.stable_id AS ensg, biotype, seq_region_start AS seqregionstart, seq_region_end AS seqregionend, ",
    "seq_region_strand AS strand, description AS name, name AS chromosome ",
    "FROM gene g, seq_region sr WHERE sr.seq_region_id = g.seq_region_id"
  )
  res <- DBI::dbSendQuery(con, sql1)
  gene <- DBI::dbFetch(res)
  DBI::dbClearResult(res)

  # --- GC content
  sql2 <- paste0(
    "SELECT stable_id AS ensg, value AS gc_content FROM gene_attrib ga JOIN gene g ON g.gene_id = ga.gene_id ",
    "WHERE attrib_type_id = (SELECT attrib_type_id FROM attrib_type WHERE code = 'GeneGC')"
  )
  res <- DBI::dbSendQuery(con, sql2)
  gc_content <- DBI::dbFetch(res)
  DBI::dbClearResult(res)

  # --- symbol
  sql3 <- paste0(
    "SELECT g.stable_id AS ensg, display_label as symbol ",
    "FROM gene g, seq_region sr, xref xr, object_xref oxr, external_db edb ",
    "WHERE sr.seq_region_id = g.seq_region_id ",
    "AND xr.xref_id = oxr.xref_id AND xr.external_db_id = edb.external_db_id ",
    "AND g.gene_id = oxr.ensembl_id AND db_name IN ('",
    paste(symbol_source, collapse = "','"),
    "')"
  )
  res <- DBI::dbSendQuery(con, sql3)
  symbol <- DBI::dbFetch(res) %>%
    unique() %>%
    dplyr::arrange(symbol)

  dbClearResult(res)

  symbol %>%
    dplyr::group_by(ensg) %>%
    dplyr::summarise(n = n()) %>%
    dplyr::filter(n > 1) %>%
    print()

  symbol2 <- symbol %>%
    dplyr::group_by(ensg) %>%
    dplyr::slice(1)

  # -- put things together
  gene %>%
    dplyr::left_join(gc_content, by = "ensg") %>%
    dplyr::left_join(symbol2, by = "ensg")
}
