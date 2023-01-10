# https://doi.org/10.1016/j.cell.2018.03.035
createCelllineSigRAS <- function() {

  con <- getPostgresqlConnection()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename) %>%
    dplyr::collect()

  alternative_celllinename <- dplyr::tbl(con, dbplyr::in_schema("cellline", "alternative_celllinename"))  %>%
    dplyr::select(celllinename, alternative_celllinename) %>%
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  file <- "https://raw.githubusercontent.com/greenelab/pancancer/master/results/ccle_Ras_classifier_scores.tsv"
  data <- read_tsv(file) %>%
    select(l = cell_line, score = weight) %>%
    separate(col = l, c("celllinename", "cl2"), extra ="drop") %>%
    select(-cl2)

  unknown <- setdiff(data$celllinename, cellline$celllinename)
  if (length(unknown) > 0) {
    data <- data %>%
      dplyr::left_join(alternative_celllinename, by = c("celllinename" = "alternative_celllinename")) %>%
      dplyr::mutate(celllinename = ifelse(is.na(celllinename.y), celllinename, celllinename.y)) %>%
      dplyr::filter(celllinename %in% cellline$celllinename) %>%
      dplyr::select(-celllinename.y) %>%
      unique()
  }

  data2 <- data %>%
    mutate(signature = "RAS")

  signature_db <- data.frame(
    signature   = "RAS",
    description = "RAS activation signature",
    unit        = "arbitrary units",
    hyperlink   = "https://doi.org/10.1016/j.celrep.2018.03.046"
  )

  list(public.genesignature = signature_db,
     cellline.cellline2genesignature = data2)
}
