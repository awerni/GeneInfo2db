getMetMap <- function() {
  con <- getPostgresqlConnection()
  
  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename) %>%
    dplyr::collect()
  
  alternative_celllinename <- dplyr::tbl(con, dbplyr::in_schema("cellline", "alternative_celllinename"))  %>%
    dplyr::select(celllinename, alternative_celllinename) %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  # -------------------------
  my_excel_file <- "metmap.xlsx"
  clean_up <- getFileDownload(my_excel_file, only_download = TRUE)
  
  data <- data.frame()
  for (s in readxl::excel_sheets(my_excel_file)) {
    data2 <- readxl::read_xlsx(my_excel_file, sheet = s) %>%
      rename(celllinename = 1) %>%
      mutate(organ = gsub("(metp500\\.|5)", "", s))
    if (nrow(data) == 0) {
      data <- data2
    } else {
      data <- data %>% bind_rows(data2)
    }
  }
  
  if (clean_up) file.remove(my_excel_file)
  
  unknown <- setdiff(data$celllinename, cellline$celllinename)
  if (length(unknown) > 0) {
    data <- data %>%
      left_join(alternative_celllinename, by = c("celllinename" = "alternative_celllinename")) %>%
      mutate(celllinename = ifelse(is.na(celllinename.y), celllinename, celllinename.y)) %>%
      filter(celllinename %in% cellline$celllinename)
  }
  
  dataDB <- data %>%
    select(celllinename, organ, met_potential = mean, ci5percent = CI.05, ci95percent = CI.95, penetrance)

  list(cellline.metmap = dataDB)
}