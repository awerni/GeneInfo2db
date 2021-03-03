#' creates parts of a Postgresql database
#'
#' @param db_part a part of the database structure stored in this package
#' @return nothing

createDatabase <- function(db_part) {
  if (db_part %in% c("recreateSchema", "geneAnnotation", "celllineDB", "db_glue")) {
    con <- getPostgresqlConnection()
    
    DBI::dbExecute(con, "BEGIN")
    sapply(str_split(get(db_part), ";", simplify = TRUE), function(s) {
      print(s)
      #res <- RPostgres::dbSendQuery(con, s)
      #RPostgres::dbClearResult(res)
      DBI::dbExecute(con, s)
    })
    dbExecute(con, "COMMIT")
    
    RPostgres::dbDisconnect(con)
  } else {
    stop("unknown database part")
  }
}
