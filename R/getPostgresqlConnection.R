# TODO: 
# Maybe it will be better to read connection info from options and add 
# function - setPostgresqlConfigFromEnviron ?

#' Get connection to postresql database.
#'
#' @param user database user
#' @param name database name
#' @param host database host
#' @param password database password
#' @param port database port (default 5432)
#'
#' @return connection to postgres database.
#' 
#' @export
#'
#' @examples
#' 
#' con <- getPostgresqlConnection()
#' DBI::dbGetQuery(con, "SELECT 1")
#' RPostgres::dbDisconnect(con)
#' 
getPostgresqlConnection <- function (
  user     = getOption("GeneInfo2db.DB_USER", default = Sys.getenv("USER")),
  name     = getOption("GeneInfo2db.DB_NAME"),
  host     = getOption("GeneInfo2db.DB_HOST"),
  password = getOption("GeneInfo2db.DB_PASSWORD"),
  port     = as.integer(getOption("GeneInfo2db.DB_PORT", default = 5432L))
) {
  drv <- RPostgres::dbDriver("Postgres")
  con <- try(RPostgres::dbConnect(drv, user = user, password = password, dbname = name, host = host, port = port))
  return(con)
}
