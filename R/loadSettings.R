#' Get password from .pgpass file
#'
#' @param dbsettings incomplete list of dbhost, dbname, dbuser, dbport, or dbpass
#' @return complete list with database configuration.
#' 
#' @note the return value of this function is used to specify DB config for \code{setDBconfig}.
#' 
#' @export
#' 
getDBConfig <- function(dbsettings) {
  
  pgpassFile <- Sys.getenv("PGPASSFILE")
  if (pgpassFile == "") pgpassFile <- "~/.pgpass"

  if(!file.exists(pgpassFile)) {
    message("No .pgpass file found. ")
    return()
  }
  
  fillMissing <- function(x, alt) {
    ifelse(is.null(x) || is.na(x), alt, x)
  } 
  
  DBname <- fillMissing(dbsettings[["dbname"]], as.character(NA))
  DBhost <- fillMissing(dbsettings[["dbhost"]], Sys.getenv("PGHOST"))
  DBport <- fillMissing(dbsettings[["dbport"]], "5432")
  DBuser <- fillMissing(dbsettings[["dbuser"]], Sys.getenv("USER"))
  DBpass <- fillMissing(dbsettings[["dbpass"]], as.character(NA))
  
  if (DBname == "" | is.na(DBname) ) {
    message("No database name found.")
    return()
  }
  
  if (DBhost == "" | is.na(DBhost)) {
    message("No database hostname found.")
    return()
  }
  
  compare <- function(x, y) (x == y | y == "*")
  
  if (DBpass == "" | is.na(DBpass) | is.null(DBpass)) {
    pgpass <- strsplit(scan("~/.pgpass", what = "", quiet = TRUE), ":")
    n <- sapply(pgpass, function(x) {
      compare(DBhost, x[[1]]) & compare(DBport, x[[2]]) & compare(DBname, x[[3]]) & compare(DBuser, x[[4]])
    })
    DBpass <- pgpass[[which(n)[1]]][[5]]
  }
 
  config <- list(
    host = DBhost,
    port = DBport,
    name = DBname,
    user = DBuser,
    pass = DBpass
  )
  
  class(config) <- "GeneInfo2DatabaseConfig"
  config
}

#' Method for printing GeneInfo2DatabaseConfig object.
#'
#' @param x GeneInfo2DatabaseConfig object.
#' @param ... not used.
#'
#' @details this function hides the password value.
#'
#' @export print.GeneInfo2DatabaseConfig
#'
print.GeneInfo2DatabaseConfig <- function(x, ...) {
  
  print(x[-5])
  cat("$pass\n    <hidden>\n")
  
  invisible(x)
}

#' Set database config.
#'
#' @param host database host or list with configuration (preferably the result 
#' of pgpass2dbConfig)
#' @param port database port
#' @param name database name
#' @param user database user
#' @param pass database password
#'
#' @note the order of arguments mimics the order values in .pgpass file.
#'
#' @return nothing. Called for side effects.
#' @export
#'
setDBconfig <- function(host, port, name, user, pass) {
  
  if(is.list(host)) {
    port <- host[["port"]]
    name <- host[["name"]]
    user <- host[["user"]]
    pass <- host[["pass"]]
    host <- host[["host"]]
  }
  
  port <- as.integer(port)
  
  options("GeneInfo2db.DB_HOST" = host)
  options("GeneInfo2db.DB_PORT" = port)
  options("GeneInfo2db.DB_NAME" = name)
  options("GeneInfo2db.DB_USER" = user)
  options("GeneInfo2db.DB_PASSWORD" = pass)
  
  message("Database config:")
  message("GeneInfo2db.DB_HOST: ", getOption("GeneInfo2db.DB_HOST"))
  message("GeneInfo2db.DB_PORT: ", getOption("GeneInfo2db.DB_PORT"))
  message("GeneInfo2db.DB_NAME: ", getOption("GeneInfo2db.DB_NAME"))
  message("GeneInfo2db.DB_USER: ", getOption("GeneInfo2db.DB_USER"))
  message("GeneInfo2db.DB_PASSWORD: ", 'getOption("GeneInfo2db.DB_PASSWORD")')
  
}

loadSettings <- function() {
  registerGeneInfoDownloadFunction()
  options("msigdb_path" = "~/Downloads/msigdb")
  options("geneinfo2db_local_filecache" = "~/Downloads/geneinfo2db_local_filecache")
}
