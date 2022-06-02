getCelllineMetMap <- function() {
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
  excel_file <- download_file_info %>%
    dplyr::filter(data_file == "metmap.xlsx") %>%
    as.list()
  
  readMetmapExcel <- function(filepath) {
    data <- data.frame()
    
    for (s in readxl::excel_sheets(filepath)) {
      data2 <- readxl::read_xlsx(filepath, sheet = s) %>%
        rename(celllinename = 1) %>%
        mutate(organ = gsub("(metp500\\.|5)", "", s))
      if (nrow(data) == 0) {
        data <- data2
      } else {
        data <- data %>% bind_rows(data2)
      }
    }
    data
  }
  
  data <- safeReadFile(excel_file$url, read_fnc = readMetmapExcel)
  
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
