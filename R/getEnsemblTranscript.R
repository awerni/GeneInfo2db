#' @export
getEnsemblTranscript <- function(con, transcriptname_source) {
  # ---transcript
  sql1 = paste0(
    "SELECT t.stable_id AS enst, t.seq_region_start as seqstart, t.seq_region_end as seqend, ",
    "t.seq_region_strand as strand, g.stable_id AS ensg, sr.name AS chromosome, ",
    "IF(g.canonical_transcript_id = t.transcript_id, TRUE, FALSE) AS iscanonical ",
    "FROM transcript t ",
    "JOIN seq_region sr ON sr.seq_region_id = t.seq_region_id ",
    "JOIN gene g ON t.gene_id = g.gene_id"
  )
  res <- DBI::dbSendQuery(con, sql1)
  transcript <- DBI::dbFetch(res)
  DBI::dbClearResult(res)

  # --- transcript name
  sql2 = paste0(
    "SELECT t.stable_id AS enst, display_label as transcriptname ",
    "FROM transcript t, seq_region sr, xref xr, object_xref oxr, external_db edb ",
    "WHERE sr.seq_region_id = t.seq_region_id ",
    "AND xr.xref_id = oxr.xref_id AND xr.external_db_id = edb.external_db_id ",
    "AND t.transcript_id = oxr.ensembl_id AND db_name = '", transcriptname_source, "'"
  )
  res <- DBI::dbSendQuery(con, sql2)
  transcript_name <- DBI::dbFetch(res)
  DBI::dbClearResult(res)

  # -- put things together
  transcript2 <- transcript |>
    dplyr::left_join(transcript_name, by = "enst") |>
    dplyr::mutate(iscanonical = ifelse(iscanonical == 1, TRUE, FALSE))
}
