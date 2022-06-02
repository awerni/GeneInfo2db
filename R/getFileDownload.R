getFileDownload <- function(dfile) {
  
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

  safeReadFile(de$url, useLocalFileRepo(de$data_file), read_fnc = guessingReadingFunction)
}
