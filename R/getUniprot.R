getUniprot <- function() {
  
  ftp_path <- "ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/"
  
  # file_sprot <-"uniprot_sprot_human.dat.gz"
  # url <- paste0(ftp_path, "taxonomic_divisions/", file_sprot)
  # if (!file.exists(file_sprot)) {
  #   download.file(url, destfile = file_sprot, method = "wget", quiet = TRUE)
  # }

  # file_trembl <- "uniprot_trembl_human.dat.gz"
  # url2 <- paste0(ftp_path, "taxonomic_divisions/", file_trembl)
  # if (!file.exists(file_trembl)) {
  #   download.file(url2, destfile = file_trembl, method = "wget", quiet = TRUE)
  # }
  # file_trembl <- "uniprot_trembl_human_part.dat"
  # trembl_anno <- read_lines(file_trembl) %>%
  #   grep("(^ID|^DE   RecName|^DE   SubName)", ., value = TRUE) %>%
  #   matrix(., ncol = 2, byrow = TRUE) %>%
  #   as.data.frame(stringsAsFactors = FALSE) %>%
  #   dplyr::mutate(V1 = gsub("(ID   |Reviewed\\;.*)", "", V1),
  #                 V2 = gsub("(DE   RecName: Full\\=|\\;)", "", V2)) %>%
  #   dplyr::mutate(V1 = gsub("(^ *| *$)", "", V1)) %>%
  #   dplyr::rename(uniprotid = V1, proteinname = V2)

  # uniprot_anno <- read_lines(file_sprot) %>%
  #   grep("(^ID|^DE   RecName)", ., value = TRUE) %>%
  #   matrix(., ncol = 2, byrow = TRUE) %>%
  #   as.data.frame(stringsAsFactors = FALSE) %>%
  #   dplyr::mutate(V1 = gsub("(ID   |Reviewed\\;.*)", "", V1),
  #          V2 = gsub("(DE   RecName: Full\\=|\\;)", "", V2)) %>%
  #   dplyr::mutate(V1 = gsub("(^ *| *$)", "", V1)) %>%
  #   dplyr::rename(uniprotid = V1, proteinname = V2)

  # ---------- accession ------
  # uniprot_anno2 <- read_lines(file_sprot) %>%
  #   grep("(^ID|^AC)", ., value = TRUE)
  # 
  # ac <- NULL
  # res <- NULL
  # for (d in uniprot_anno2) {
  #   if (grepl("^ID", d)) {
  #     d1 = gsub("(ID   |Reviewed\\;.*)", "", d)
  #     d1 = gsub("(^ *| *$)", "", d1)
  #     res <- c(res, ac)
  #     res <- c(res, d1)
  #     ac <- NULL
  #   }
  #   if (grepl("^AC", d)) {
  #     ac <- paste(ac, gsub("(AC   |\\;)", "", d))
  #   }
  # }
  # res <- c(res, ac)
  # 
  # uniprot_accession <- matrix(res, ncol = 2, byrow = TRUE) %>%
  #   as.data.frame(stringsAsFactors = FALSE) %>%
  #   dplyr::mutate(V2 = gsub("(^ *| *$)", "", V2)) %>%
  #   dplyr::mutate(V2 = strsplit(V2, " ")) %>%
  #   tidyr::unnest(cols = c(V2)) %>%
  #   dplyr::rename(uniprotid = V1, accession = V2)
  
  # ---------------------------
  
  protein_IDs <- getTaiga("protein_IDs")
  
  file_uniprot2 <-"HUMAN_9606_idmapping_selected.tab.gz"
  url3 <- paste0(ftp_path, "idmapping/by_organism/", file_uniprot2)
  
  if (!file.exists(file_uniprot2)) {
    download.file(url3, destfile = file_uniprot2, method = "wget", quiet = TRUE)
  }
  
  id_map <- read_tsv(file_uniprot2, col_names = FALSE) %>%
    dplyr::select(accession = X1, uniprotid = X2, geneid = X3, ensg = X19, enst = X20, ensp = X21)
  
  id_map2 <- protein_IDs %>%
    dplyr::mutate(accession = gsub("\\-.*{1}", "", Uniprot_Acc)) %>%
    dplyr::left_join(id_map, by = "accession") %>%
    dplyr::select(-uniprotid) %>%
    dplyr::rename(uniprotid = Uniprot)
  
  uniprot_anno <- id_map2 %>%
    dplyr::select(uniprotid, proteinname = Description) %>%
    dplyr::mutate(proteinname = gsub(".*_.*? {1}", "", proteinname)) %>%
    dplyr::mutate(proteinname = gsub("Isoform .*? of {1}", "", proteinname)) %>%
    unique()
  
  con <- getPostgresqlConnection()
  
  allENSG <- dplyr::tbl(con, "gene") %>%
    dplyr::filter(species == "human" & grepl("^ENSG", ensg)) %>%
    dplyr::select(ensg) %>%
    dplyr::collect()
  
  allGeneID <- dplyr::tbl(con, "entrezgene")  %>%
    dplyr::filter(taxid == 9606) %>% 
    dplyr::select(geneid) %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  uniprot_accession <- id_map2 %>%
    select(uniprotid, accession) %>%
    filter(uniprotid %in% protein_IDs$Uniprot) %>%
    unique()
  
  uniprot_geneid <- id_map2 %>%
    dplyr::select(uniprotid, geneid) %>%
    unique() %>%
    dplyr::filter(!is.na(geneid)) %>%
    dplyr::mutate(geneid = strsplit(geneid, "; ")) %>%
    tidyr::unnest(cols = c(geneid)) %>%
    dplyr::mutate(geneid = as.numeric(geneid)) %>%
    dplyr::filter(geneid %in% allGeneID$geneid)
  
  uniprot_ensg <- id_map2 %>%
    dplyr::select(uniprotid, ensg) %>%
    unique() %>%
    dplyr::filter(!is.na(ensg)) %>%
    dplyr::mutate(ensg = strsplit(ensg, "; ")) %>%
    tidyr::unnest(cols = c(ensg)) %>%
    dplyr::filter(ensg %in% allENSG$ensg)  
  
  list(public.uniprot = uniprot_anno,
       public.uniprotaccession = uniprot_accession,
       public.uniprot2entrezgene = uniprot_geneid,
       public.uniprot2ensemblgene = uniprot_ensg)
}