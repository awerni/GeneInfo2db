#' Get database config from .pgpass file
#'
#' @param line which line of .pgpass should be used
#' @param .pgpassPaths path to .pgpass file. Default value should work in most 
#' cases.
#'
#' @return list with database configuration.
#' 
#' @note To use specific config, it need to be set using \code{setDBconfig}.
#' 
#' @export
#' 
pgpass2dbConfig <- function(line = 1, .pgpassPaths = c(".pgpass", "~/.pgpass")) {
  
  existingFiles <- .pgpassPaths[file.exists(.pgpassPaths)]
  
  if(length(existingFiles) == 0) {
    message("No .pgpass file found. ",
    "Use Renviron to specify default vaues for postgres connection.")
    return()
  }
  
  file <- existingFiles[1]
  content <- readLines(file, warn = FALSE)
  
  if(line > length(content)) {
    stop(".pgpass does not have ", line, " lines")
  }
  content <- content[[line]]
  
  pgpassContent <- strsplit(content, split = ":")[[1]]
  
  config <- list(
    host = pgpassContent[1], 
    port = as.integer(pgpassContent[2]),
    name = pgpassContent[3],
    user = pgpassContent[4],
    pass = pgpassContent[5]
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
  
  message("Data base config:")
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
