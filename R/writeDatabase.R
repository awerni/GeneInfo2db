writeDatabase <- function(species_data) {
  con <- getPostgresqlConnection()
  for (myT in names(species_data)) {
    myST <- strsplit(myT, split = "\\.")[[1]]
    if (length(myST) != 2) stop("tablename must contain the schema and tablename")
    RPostgres::dbWriteTable(
      con,
      RPostgres::Id(schema = myST[[1]], table = myST[[2]]),
      species_data[[myT]],
      append = TRUE,
      overwrite = FALSE,
      row.names = FALSE
    )
  }
  RPostgres::dbDisconnect(con)
}