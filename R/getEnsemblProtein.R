getEnsemblProtein <- function(db_info, species_name) {
  db <- db_info |>
    dplyr::filter(species == species_name) |>
    as.list()
  
  conM <- getEnsemblDBConnection(db$database)
  
  sql1 = paste0(
    "select t.stable_id AS enst, tl.stable_id AS ensp from transcript t ",
    "JOIN translation tl on t.transcript_id = tl.transcript_id"
  )
  
  res <- DBI::dbSendQuery(conM, sql1)
  translation <- DBI::dbFetch(res)
  DBI::dbClearResult(res)
  
  # sql2 <- "select * from gene_archive"
  # res <- DBI::dbSendQuery(conM, sql2)
  # translation2 <- DBI::dbFetch(res)
  # DBI::dbClearResult(res)
  
  # translation3 <- translation2 |>
  #   select(enst = transcript_stable_id, ensp = translation_stable_id) |>
  #   unique()
  
  # sql3 <- "SELECT * FROM protein_feature"
  # res <- DBI::dbSendQuery(conM, sql3)
  # protein_feature <- DBI::dbFetch(res)
  # DBI::dbClearResult(res)
  
  dbDisconnect(conM)
  
  #myT <- bind_rows(translation3, translation) |>
  myT <- translation |>  
    unique() |>
    dplyr::filter(!is.na(enst) & !is.na(ensp))
  
}

# id_map <- read_tsv("~/Download/HUMAN_9606_idmapping_selected.tab.gz", col_names = FALSE) |>
#   dplyr::select(accession = X1, uniprotid = X2, geneid = X3, ensg = X19, enst = X20, ensp = X21)
# 
# id_map2 <- id_map |>
#   select(enst, ensp) |>
#   mutate(enst = str_split(enst, "; "),
#          ensp = str_split(ensp, "; ")) |>
#   unnest(cols = c(enst, ensp)) |>
#   dplyr::filter(!is.na(ensp)) |>
#   full_join(myT, by = "enst")

