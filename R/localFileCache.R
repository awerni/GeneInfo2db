#' Check if geneinfo2db_local_filecache direcory exists. If not creates this path.
#'
#' @param subdir direcotry for storing local copies of remote files.
#'
#' @return path 
#'
#' @examples
#' 
#' \donttest{
#' checkLocalFileRepo(tempdir())
#' }
#' 
checkLocalFileRepo <- function(subdir = getOption("geneinfo2db_local_filecache")) {
  log_trace("Check for subdir '{subdir}' existence: {dir.exists(subdir)}")
  if(!dir.exists(subdir)) {
    log_trace("'{subdir}' does not exists. Creating it.")
    dir.create(subdir, showWarnings = FALSE, recursive = TRUE)
  }
  return(subdir)
}

#' Returns the path for local file cache.
#'
#' @return Path to local file cache.
#'
#' @details This function also checks if the local cache exists by calling \code{\link{checkLocalFileRepo}}.
#'
#' @examples
#' 
#' \dontrun{
#' getLocalFileRepo()
#' }
#' 
getLocalFileRepo <- function() {
  path <- getOption("geneinfo2db_local_filecache", "")
  checkLocalFileRepo(path)
  path
}

#' Set path to local file cache.
#'
#' @param path path to local file cache.
#'
#' @return
#' @export
#'
#' @examples
#' 
setLocalFileRepo <- function(path) {
  options("geneinfo2db_local_filecache" = path)
  invisible(getLocalFileRepo())
}

#' Modify file path to include local file cache.
#'
#' @param path path to file to download.
#'
#' @return a file path consisting the local file chace path.
#' @examples
#' 
#' \dontrun{
#' useLocalFileRepo("xd.rds")
#' }
#' 
useLocalFileRepo <- function(path) {
  
  repoPath <- getLocalFileRepo()
  if(is.null(repoPath) || is.na(repoPath) || repoPath == "") {
    # local file repo is not used - a path without modification is being returned
    path
  } else {
    file.path(repoPath, path)
  }
}
