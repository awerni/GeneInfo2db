#' @export
writeEntrezGene2EnsemblGene <- function(species_data) {

  species_data <- species_data %>%
    dplyr::mutate(sql = paste0("SELECT setEntrezGene2EnsemblGene('", ensg, "',", geneid, ")"))

  con <- getPostgresqlConnection()
  devnull <- sapply(species_data$sql, function(s) RPostgres::dbGetQuery(con, s))
  RPostgres::dbDisconnect(con)
}
