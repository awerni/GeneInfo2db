#' writes a list of data frames into a Postgresql database
#'
#' @param table_data a list of data frames
#' @return nothing

writeDatabase <- function(table_data) {
  con <- getPostgresqlConnection()
  for (myT in names(table_data)) {
    myST <- strsplit(myT, split = "\\.")[[1]]
    if (length(myST) != 2) stop("list element name must consist of schema and tablename")
    RPostgres::dbWriteTable(
      con,
      RPostgres::Id(schema = myST[[1]], table = myST[[2]]),
      table_data[[myT]],
      append = TRUE,
      overwrite = FALSE,
      row.names = FALSE
    )
  }
  RPostgres::dbDisconnect(con)
}
