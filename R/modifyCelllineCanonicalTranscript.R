#' @export
modifyCelllineCanonicalTranscript <- function() {
  con <- getPostgresqlConnection()

  sql <- paste0("SELECT ensg, p.enst, iscanonical, count(*)::INT4 AS n FROM transcript t JOIN  ",
                "cellline.processedsequence p ON t.enst = p.enst GROUP BY ensg, p.enst, iscanonical")
  
  mut_enst <- DBI::dbGetQuery(con, sql)

  mut_enst2 <- mut_enst |>
    dplyr::group_by(ensg) |>
    mutate(share = n/sum(n)) |>
    filter(share > 0.8 & !iscanonical) |>
    dplyr::mutate(sql1 = paste0("UPDATE transcript SET iscanonical = FALSE WHERE ensg = '", ensg, "'"),
                  sql2 = paste0("UPDATE transcript SET iscanonical = TRUE WHERE enst = '", enst, "'"))

  sapply(mut_enst2$sql1, function(s) DBI::dbExecute(con, s))
  sapply(mut_enst2$sql2, function(s) DBI::dbExecute(con, s))

  RPostgres::dbDisconnect(con)

  return(TRUE)
}
