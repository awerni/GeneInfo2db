modifyTissueCanonicalRNAseqRun() {
  con <- getPostgresqlConnection()
  
  sql <- paste0("SELECT * FROM tissue.rnaseqrun WHERE tissuename IN (",
                "SELECT tissuename FROM tissue.rnaseqrun WHERE not xenograft AND canonical ",
                "GROUP BY tissuename HAVING count(*) > 1)")
  
  rnaseq_run <- DBI::dbGetQuery(con, sql) %>% 
    dplyr::group_by(tissuename) %>%  
    dplyr::mutate(rank = row_number()) %>%
    dplyr::ungroup() %>%
    dplyr::filter(rank > 1) %>%
    dplyr::mutate(sql = paste0("UPDATE tissue.rnaseqrun SET canonical = FALSE WHERE rnaseqrunid = '", rnaseqrunid, "'"))
  
  sapply(rnaseq_run$sql, function(s) DBI::dbExecute(con, s))
  
  RPostgres::dbDisconnect(con)
  
  return(TRUE)
}