getTaiga <- function(dfile) {
  
  if (grepl("@", dfile)) {
    dfile_part <- strsplit(dfile, "@")[[1]]
    
    ti <- taiga_info %>%
      dplyr::filter(data_file == dfile_part[1]) %>%
      dplyr::filter(grepl(dfile_part[2], data_name)) %>%
      as.list()
    
  } else {
    ti <- taiga_info %>%
      dplyr::filter(data_file == dfile) %>%
      as.list()
  }
  
  info_len <- sum(sapply(ti, length))
  if (info_len == 0) stop("no such file")
  if (info_len != 3) stop("ambiguous file info")
  
  taigr::load.from.taiga(
    data.name = ti$data_name,
    data.version = ti$data_version,
    data.file = ti$data_file
  )
}
