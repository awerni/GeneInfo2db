getVersion <- function() {
  list(public.information = getOption("GeneInfo2db.version"))
}

getFileVersion <- function() {
  env <- new.env()
  data("file_version", package = "GeneInfo2db", envir = env)
  env$file_version
}
