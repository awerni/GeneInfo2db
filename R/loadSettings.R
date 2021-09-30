parsePgPass <- function(.pgpassPaths = c(".pgpass", "~/.pgpass")) {
  
  existingFiles <- .pgpassPaths[file.exists(.pgpassPaths)]
  
  if(length(existingFiles) == 0) {
    message("No .pgpass file found. ",
    "Use Renviron to specify default vaues for postgres connection.")
    return()
  }
  
  file <- existingFiles[1]
  content <- readLines(file, warn = FALSE)
  
  pgpassContent <- strsplit(content, split = ":")[[1]]
  
  options("GeneInfo2db.DB_HOST" = pgpassContent[1])
  options("GeneInfo2db.DB_PORT" = as.integer(pgpassContent[2]))
  options("GeneInfo2db.DB_NAME" = pgpassContent[3])
  options("GeneInfo2db.DB_USER" = pgpassContent[4])
  options("GeneInfo2db.DB_PASSWORD" = pgpassContent[5])
  
  message("Default postgres config infered from ", file, ":")
  message("GeneInfo2db.DB_HOST: ", getOption("GeneInfo2db.DB_HOST"))
  message("GeneInfo2db.DB_PORT: ", getOption("GeneInfo2db.DB_PORT"))
  message("GeneInfo2db.DB_NAME: ", getOption("GeneInfo2db.DB_NAME"))
  message("GeneInfo2db.DB_USER: ", getOption("GeneInfo2db.DB_USER"))
  message("GeneInfo2db.DB_PASSWORD: ", 'getOption("GeneInfo2db.DB_PASSWORD"))')
  
}

loadSettings <- function() {
  
  registerGeneInfoDownloadFunction()
  options("dbname" = "bioinfo.hg38")
  options("dbhost" = "vie-bio-postgres")
  options("msigdb_path" = "~/Downloads/msigdb")
  parsePgPass()
  options("geneinfo2db_local_filecache" = "~/Downloads/geneinfo2db_local_filecache")
}
