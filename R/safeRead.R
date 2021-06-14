#' Get file size info from the url.
#'
#' @param url url to test. Can be a ftp url.
#'
#' @return file size of the file from the url.
#'
#' @examples
#' 
#' @importFrom RCurl getURL
#' @importFrom stringistri_extract_all_regex
#' @importFrom httr HEAD
#' 
#' \dontrun{
#' download_filesize("ftp://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/Homo_sapiens.gene_info.gz")
#' }
#' 
download_filesize <- function(url) {
  
  if(substr(url,1,3) == "ftp") {
    size <- RCurl::getURL(url, nobody = 1L, header = 1L) # get header without body
    size <- (
      stringi::stri_extract_all_regex(size, "Content-Length: [0-9]+")
      %>% stringi::stri_extract_all_regex("[0-9]+") 
      %>% unlist() 
      %>% as.numeric()
    )
    return(size)
  }
  
  as.numeric(httr::HEAD(url)$headers$`content-length`)
}


safeDownloadFile <- function(url, filename, .retries = 20, .waitTime = 20) {
    
  if(.retries < 0) stop(".retries must be greater or equal to zero!")
  
  status <- tryCatch(download.file(url, filename), error = function(err) {
    log_error("Cannot download the {url}.")
    if(file.exists(filename)) unlink(filename)
    err
  })
    
  if(inherits(status, "error")) {
    
    if(.retries == 0) {
      stop(status)
    } else {
      log_trace("Cannot download file - Retrying {url} - number of retries left {.retries - 1}")
      Sys.sleep(.waitTime)
      res <- safeDownloadFile(url, filename, .retries - 1, .waitTime)
      return(res)
    }
  }
  
  list(status = status, .retries = .retries)
}

  
  
  
#' Safe read file from url.
#'
#' @param url url to file.
#' @param read_fnc function used to read file from disk. Default \code{\link{read_tsv}} from \code{readr} package.
#' @param subdir subdirectory for a local cache. Default: \code{gene-data/ftp-ncbi}. Could be a path returned from \code{\link{tempdir}}.
#' @param ... other parameres passed to \code{read_fnc}.
#'
#' @return
#' 
#' A data.frame or tibble resulting from using the \code{read_fnc}.
#' 
#' @details 
#' 
#' This function is a safer alternative to \code{read_tsv(url)}. When there will be any problem with the connection, \code{safe_read_file}
#' will fail, but the \code{read_tsv(url)} can return partial result (meaning - all rows downloaded up to the loss connection point).
#' 
#' @export
#' 
#' @importFrom logger log_trace
#'
#' @examples
#' 
#' \dontrun{
#' safeReadFile("ftp://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/Homo_sapiens.gene_info.gz")
#' }
#' 
safeReadFile <- function(url, read_fnc = readr::read_tsv, subdir = "gene-data/ftp-ncbi", .retries = 20, .waitTime = 20, ...) {
  
  filename <- useLocalFileRepo(basename(url))
  
  # Checking if the file exists:
  # If yes, then it also check the local and remote file sizes - if they are different
  # then the local copy is removed
  # we assume that the file was only partially downloaded or a new version is available
  # in both cases - the downloading needs to start from scratch
  if (file.exists(filename)) {
    size2download <- download_filesize(url)
    currentSize <- file.info(filename)$size
    
    logger::log_trace("{filename}: Size to download: {size2download}, Current Size: {currentSize}, Match size: {size2download == currentSize}")
    if (currentSize != size2download) {
      logger::log_trace("Removing old instance of {filename} - sizes do not match.")
      file.remove(filename)
    }
  }
  
  
  # If file is not in a local cache, the function below tries to download it.
  # Note that it uses safeDownloadFile which tries .retries times if it is not able to succeed.
  if(!file.exists(filename)) {
    log_trace("File {filename} not available local cache. Downloading from {url} using safeDownloadFile().")
    status <- safeDownloadFile(url, filename, .retries, .waitTime)
    .retries <- status$.retries # update retries to include retires used in recurrent safeDownloadFile calls.
    
  } else {
    log_trace("File {filename} present in local cache. No need to download.")
  }
  
  
  # Safely reading the file:
  # it needs to use tryCatch becaue sometimes even when the safeDownloadFile succeed, the archive still
  # can be corrupted leading to error on this stage. In such case (the reading below fails), safeReadFile
  # calls itself once again to redownload hopefully uncorrupted verion of the file.
  res <- tryCatch(
    read_fnc(filename, ...)
    , error = function(e) {
      if(file.exists(filename)) {
        log_error("{filename} cannot be read. Removing it.")
        unlink(filename)
      } else {
        log_error("{filename} does not exists.")
      }
      e
    }
  )
  
  # Retry if the read function was not able to read the file. 
  if(inherits(res, "error")) {
    
    if(.retries == 0) {
      stop(res)
    } else {
      log_trace("Problem with downloaded file - Retrying {url} - number of retries left {.retries - 1}")
      Sys.sleep(.waitTime)
      res <- safeReadFile(url, read_fnc = read_fnc, subdir = subdir, .retries = .retries - 1, .waitTime = .waitTime, ...)
    }
  }
  res
}
