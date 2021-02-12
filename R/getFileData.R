getFileData <- function(dfile) {
  if (getOption("useFileDownload")) {
    getFileDownload(dfile) 
  } else {
    getTaiga(dfile)
  }
}