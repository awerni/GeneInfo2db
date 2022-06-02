getEnsemblExon <- function(con) {
  # --- exon
  sql3 <- paste0(
    "SELECT e.stable_id as ense, e.seq_region_start AS seqstart, e.seq_region_end AS seqend, sr.name AS chromosome ",
    "FROM exon e, seq_region sr " ,
    "WHERE sr.seq_region_id = e.seq_region_id"
  )
  res <- DBI::dbSendQuery(con, sql3)
  exon <- DBI::dbFetch(res)
  DBI::dbClearResult(res)

  # --- transcript 2 exon
  sql8 <- paste0(
    "SELECT e.stable_id AS ense, t.stable_id AS enst, et.rank AS exon, tl.seq_start AS transstart, t2.seq_end AS transend ",
    "FROM exon e ",
    "JOIN exon_transcript et ON e.exon_id = et.exon_id " ,
    "JOIN transcript t ON et.transcript_id = t.transcript_id " ,
    "LEFT OUTER JOIN translation tl ON t.transcript_id = tl.transcript_id AND e.exon_id = tl.start_exon_id ",
    "LEFT OUTER JOIN translation t2 ON t.transcript_id = t2.transcript_id AND e.exon_id = t2.end_exon_id"
  )
  res <- DBI::dbSendQuery(con, sql8)
  transcript2exon <- DBI::dbFetch(res)
  DBI::dbClearResult(res)

  list(exon = exon, transcript2exon = transcript2exon)
}
