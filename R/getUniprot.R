getUniprot <- function() {

  # ----------------------------
  con <- getPostgresqlConnection()

  allENSG <- dplyr::tbl(con, "gene") |>
    dplyr::filter(species == "human" & grepl("^ENSG", ensg)) |>
    dplyr::select(ensg) |>
    dplyr::collect()

  allGeneID <- dplyr::tbl(con, "entrezgene")  |>
    dplyr::filter(taxid == 9606) |>
    dplyr::select(geneid) |>
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # ---------------------------
  ftp_path <- "https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/"
  file_uniprot2 <-"HUMAN_9606_idmapping_selected.tab.gz"
  url3 <- paste0(ftp_path, file_uniprot2)

  if (!file.exists(file_uniprot2)) {
    download.file(url3, destfile = file_uniprot2, method = "wget", quiet = TRUE)
  }
  # ---------------------------

  dfile <- "protein_quant_current_normalized.csv.gz"
  protein.quant.current.normalized <- getFileData(dfile)

  uniprot_anno <- protein.quant.current.normalized |>
    dplyr::select(uniprotid = Uniprot, proteinname = Description) |>
    dplyr::mutate(proteinname = gsub(".*_.*? {1}", "", proteinname)) |>
    dplyr::mutate(proteinname = gsub("Isoform .*? of {1}", "", proteinname)) |>
    unique()

  uniprot_accession <- protein.quant.current.normalized |>
    dplyr::select(uniprotid = Uniprot, accession = Uniprot_Acc) |>
    dplyr::mutate(accession = gsub("\\-.*{1}", "", accession)) |>
    unique()

  # ------------ mappings to ENSG and geneid ---------------
  #id_map <- getFileData("HUMAN_9606_idmapping_selected.tab.gz")
  ftp_path <- "https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/"
  file_uniprot2 <-"HUMAN_9606_idmapping_selected.tab.gz"
  url3 <- paste0(ftp_path, file_uniprot2)

  id_map <- safeReadFile(url3, col_names = FALSE) |>
    dplyr::select(accession = X1, uniprotid = X2, geneid = X3, ensg = X19, enst = X20, ensp = X21)

  id_map2 <- protein.quant.current.normalized |>
    dplyr::select(Protein_Id, Uniprot_Acc, Uniprot, Description) |>
    dplyr::mutate(accession = gsub("\\-.*{1}", "", Uniprot_Acc)) |>
    dplyr::left_join(id_map, by = "accession") |>
    dplyr::select(-uniprotid, -Uniprot_Acc) |>
    dplyr::rename(uniprotid = Uniprot)

  uniprot_geneid <- id_map2 |>
    dplyr::select(uniprotid, geneid) |>
    unique() |>
    dplyr::filter(!is.na(geneid)) |>
    dplyr::mutate(geneid = ifelse(grepl(";", geneid), strsplit(geneid, "; "), geneid)) |>
    tidyr::unnest(cols = c(geneid)) |>
    dplyr::mutate(geneid = as.numeric(geneid)) |>
    dplyr::filter(geneid %in% allGeneID$geneid)

  uniprot_ensg <- id_map2 |>
    dplyr::select(uniprotid, ensg) |>
    unique() |>
    dplyr::filter(!is.na(ensg)) |>
    dplyr::mutate(ensg = ifelse(grepl(";", ensg), strsplit(ensg, "; "), ensg)) |>
    tidyr::unnest(cols = c(ensg)) |>
    dplyr::mutate(ensg = gsub("\\..*", "", ensg)) |>
    dplyr::filter(ensg %in% allENSG$ensg)

  list(public.uniprot = uniprot_anno,
       public.uniprotaccession = uniprot_accession,
       public.uniprot2entrezgene = uniprot_geneid,
       public.uniprot2ensemblgene = uniprot_ensg)
}
