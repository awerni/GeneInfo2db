getFileDownload <- function(dfile, only_download = FALSE) {
  
  if (grepl("@", dfile)) {
    dfile_part <- strsplit(dfile, "@")[[1]]
    
    de <- download_file_info %>%
      dplyr::filter(data_file == dfile_part[1]) %>%
      dplyr::filter(grepl(dfile_part[2], data_name)) %>%
      as.list()
    
  } else {
    de <- download_file_info %>%
      dplyr::filter(data_file == dfile) %>%
      as.list()
  }

  #~data_name, ~url, ~data_file,

  clean_up <- FALSE
  if (file.exists(de$data_file)) {
    if (file.info(de$data_file)$size == 0) file.remove(de$data_file)
  }
  if (!file.exists(de$data_file)) {
    download.file(de$url, destfile = de$data_file, method = "wget", quiet = TRUE)
    clean_up <- TRUE
  }
  
  if (only_download) return(clean_up)
  
  if (coalesce(readxl::format_from_signature(de$data_file) == "xlsx", FALSE)) {
    data <- readxl::read_xlsx(de$data_file,  guess_max = 10000)
  } else {
    l <- readLines(de$data_file, n = 1)
    if (grepl("\t", l)) {
      data <- readr::read_tsv(de$data_file, na = c("", "NA"))
    } else if (grepl(",", l)) {
      data <- readr::read_csv(de$data_file, na = c("", "NA"))
    } else if (grepl(";", l)) {
      data <- readr::read_delim(de$data_file, delim = ";", na = c("", "NA"))
    } else {
      data <- readr::read_csv2(de$data_file, na = c("", "NA"))
    }
  }
  if (clean_up) file.remove(de$data_file)
  
  return(data)
}