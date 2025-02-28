#' Get file size info from the URL.
#'
#' @param URL URL to test. Can be a ftp URL.
#'
#' @return file size of the file from the URL.
#'
#' @importFrom RCurl getURL
#' @importFrom stringi stri_extract_all_regex
#' @importFrom httr HEAD
#' @importFrom logger log_trace
#'
#' @examples
#'
#'
#' \dontrun{
#' download_filesize("https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/Homo_sapiens.gene_info.gz")
#' }
#' @export
download_filesize <- function(URL) {

  rcurlFileSize <- function(URL) {

    if (getOption("GeneInfo2db.ExperimentalCurlSizeRequest", default = FALSE)) {
      # this is the most experimental implementation but it should work
      # in most places. Some servers does not support nobody request
      # -L for following to a different location (e.g. figshare uses AWS). otherwise size = 0
      size <- paste(system2("curl", paste("-s -I -L -X GET", URL), TRUE), collapse = "\n")
    } else {
      size <- RCurl::getURL(URL, nobody = 1L, header = 1L) # get header without body
    }
    stringi::stri_extract_all_regex(size, "Content-Length: [0-9]+") |>
      unlist() |>
      stringi::stri_extract_all_regex("[0-9]+") |>
      unlist() |>
      as.numeric() |>
      max()
  }

  if (substr(URL, 1, 3) == "ftp") {
    return(rcurlFileSize(URL))
  }

  size <- as.numeric(httr::HEAD(URL)$headers$`content-length`)
  if (length(size) == 0) size <- rcurlFileSize(URL)
  size
}


safeDownloadFile <- function(URL, filename, .retries = 20, .waitTime = 20) {

  if(.retries < 0) stop(".retries must be greater or equal to zero!")

  # Checking if the file exists:
  # If yes, then it also check the local and remote file sizes - if they are different
  # then the local copy is removed
  # we assume that the file was only partially downloaded or a new version is available
  # in both cases - the downloading needs to start from scratch
  if (file.exists(filename)) {
    size2download <- download_filesize(URL)
    currentSize <- file.info(filename)$size

    logger::log_trace("{filename}: Size to download: {size2download}, Current Size: {currentSize}, Match size: {size2download == currentSize}")
    if (currentSize != size2download) {
      logger::log_trace("Removing old instance of {filename} - sizes do not match.")
      file.remove(filename)
    } else {
      logger::log_trace("File is already in cache and it's good to go.")
      return(list(status = 0, .retries = .retries))
    }
  }

  logger::log_trace("File {filename} not available local cache. Downloading from {URL} using safeDownloadFile().")

  status <- tryCatch(download.file(URL, filename), error = function(err) {
    logger::log_error("Cannot download the {URL}.")
    if(file.exists(filename)) unlink(filename)
    err
  })

  if(inherits(status, "error")) {

    if(.retries == 0) {
      stop(status)
    } else {
      logger::log_trace("Cannot download file - Retrying {URL} - number of retries left {.retries - 1}")
      Sys.sleep(.waitTime)
      res <- safeDownloadFile(URL, filename, .retries - 1, .waitTime)
      return(res)
    }
  }

  return(list(status = status, .retries = .retries))
}

#' Safe read file from URL.
#'
#' @param URL URL to file.
#' @param read_fnc function used to read file from disk. Default \code{\link{read_tsv}} from \code{readr} package.
#' @param ... other parameres passed to \code{read_fnc}.
#'
#' @return
#'
#' A data.frame or tibble resulting from using the \code{read_fnc}.
#'
#' @details 
#'
#' This function is a safer alternative to \code{read_tsv(URL)}. When there will be any problem with the connection, \code{safe_read_file}
#' will fail, but the \code{read_tsv(URL)} can return partial result (meaning - all rows downloaded up to the loss connection point).
#'
#' @export
#'
#' @importFrom logger log_trace
#'
#' @examples
#'
#' \dontrun{
#' safeReadFile("https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/Homo_sapiens.gene_info.gz")
#' }
#' 
safeReadFile <- function(URL, filename = NULL, read_fnc = readr::read_tsv, .retries = 20, .waitTime = 20, ...) {

  if(is.null(filename)) {
    logger::log_trace("filename in safeReadFile is NULL using basename(URL): {basename(URL)}")
    filename <- basename(URL)
    filename <- useLocalFileRepo(filename)
  }

  # If file is not in a local cache, the function below tries to download it.
  # Note that it uses safeDownloadFile which tries \code{.retries} times if it is not able to succeed in a given attempt.
  status <- safeDownloadFile(URL, filename, .retries, .waitTime)
  .retries <- status$.retries # update retries to include retires used in recurrent safeDownloadFile calls.

  # Safely reading the file:
  # it needs to use tryCatch because sometimes even when the safeDownloadFile succeed, the archive still
  # can be corrupted leading to error on this stage. In such case (the reading below fails), safeReadFile
  # calls itself once again to redownload hopefully uncorrupted version of the file.
  res <- tryCatch(
    read_fnc(filename, ...)
    , error = function(e) {
      if(file.exists(filename)) {
        logger::log_error("{filename} cannot be read. Removing it.")
        unlink(filename)
      } else {
        logger::log_error("{filename} does not exists.")
      }
      e
    }
  )

  # Retry if the read function was not able to read the file. 
  if(inherits(res, "error")) {

    if(.retries == 0) {
      stop(res)
    } else {
      logger::log_trace("Problem with downloaded file - Retrying {URL} - number of retries left {.retries - 1}")
      Sys.sleep(.waitTime)
      res <- safeReadFile(URL, read_fnc = read_fnc, .retries = .retries - 1, .waitTime = .waitTime, ...)
    }
  }
  res
}


############ Guess file reading function ############
#' Guess reading function from its content (e.g. csv, tab separated etc) and use that function to read a file.
#'
#' @param filepath 
#'
#' @return a data frame resulting from read the file
#'
#'
#' @importFrom dplyr coalesce
#' @importFrom readxl read_xlsx
#'
#' @export
guessingReadingFunction <- function(filepath) {

  if (dplyr::coalesce(readxl::format_from_signature(filepath) == "xlsx", FALSE)) {
    log_trace("Using readxl::read_xlsx to read {filepath}")
    readxl::read_xlsx(filepath,  guess_max = 10000)
  } else {
    l <- readLines(filepath, n = 1)
    if (grepl("\t", l)) {
      logger::log_trace("Using readr::read_tsv to read {filepath}")
      readr::read_tsv(filepath, na = c("", "NA"), guess_max = 2000)
    } else if (grepl(",", l)) {
      logger::log_trace("Using readr::read_csv to read {filepath}")
      readr::read_csv(filepath, na = c("", "NA"), guess_max = 2000)
    } else if (grepl(";", l)) {
      logger::log_trace("Using readr::read_delim with delim = ';' to read {filepath}")
      readr::read_delim(filepath, delim = ";", na = c("", "NA"), guess_max = 2000)
    } else {
      logger::log_trace("Using readr::read_csv2 to read {filepath}")
      readr::read_csv2(filepath, na = c("", "NA"), guess_max = 2000)
    }
  }
}
