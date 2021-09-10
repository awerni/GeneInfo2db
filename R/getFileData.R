getFileData <- function(dfile) {
  
  getFileDownloadFunction <- getOption("GeneInfo2db.getFileDownload")
  getFileDownloadFunction(dfile)

}


#' Registers GeneInfo2db default function used 
#' 
#' @param fun function used for downloading file.
#' 
#' @details This function is for advanced users only. It allows to
#' change a function that is used to download source files.
#'
#' @return no value returned. Called for side effects.
#' @export
registerGeneInfoDownloadFunction <- function(fun = getFileDownload, version = file_version) {
  options("GeneInfo2db.getFileDownload" = fun)
  options("GeneInfo2db.version" = file_version)
}
