#' @export
getCelllineMutation_CCLE <- function() {
  con <- getPostgresqlConnection()

  transcript <- dplyr::tbl(con, "transcript") |>
    dplyr::inner_join(dplyr::tbl(con, "gene"), by = "ensg") |> 
    dplyr::filter(species == "human")  |> 
    dplyr::select(enst) |>
    dplyr::collect()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  |>
    dplyr::filter(species == "human")  |> 
    dplyr::select(celllinename, depmap) |>
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  CCLE.mutations <- getFileData("CCLE_mutations")

  calcZygosity <- function(dna_zyg) {
    data.frame(x = dna_zyg) |> 
      dplyr::mutate(x = ifelse(is.na(x) | x == "", "NA:NA", x)) |>
      tidyr::separate(x, c("alt", "ref"), convert = TRUE) |>
      dplyr::mutate(rnazygosity = alt/(alt+ref)) |>
      pull("rnazygosity")
  }

  CCLE.mutations2 <- CCLE.mutations |>
    dplyr::rename(depmap = DepMap_ID, enst = Annotation_Transcript) |>
    dplyr::filter(cDNA_Change != "" & Protein_Change != "") |>
    dplyr::filter(cDNA_Change != " " & Protein_Change != " ") |>
    dplyr::filter(!(is.na(cDNA_Change) & is.na(Protein_Change))) |>
    dplyr::filter(Variant_annotation != "silent") |>
    dplyr::mutate(dnazyg = calcZygosity(CGA_WES_AC), #t_alt_count/(t_alt_count + t_ref_count),
                  rnazyg = calcZygosity(RNAseq_AC)) |>
    dplyr::group_by(depmap, enst) |>
    dplyr::summarize(dnamutation = paste(cDNA_Change, collapse = ";"),
                     aamutation = paste(Protein_Change, collapse = ";"),
                     dnazygosity = ifelse(!all(is.na(dnazyg)), max(dnazyg, na.rm = TRUE), NA),
                     rnazygosity = ifelse(!all(is.na(rnazyg)), max(rnazyg, na.rm = TRUE), NA)) |>
    dplyr::ungroup() |>
    dplyr::mutate(enst = gsub("\\..*$", "", enst)) |>
    dplyr::inner_join(cellline, by = "depmap") |>
    dplyr::filter(enst %in% transcript$enst) |>
    dplyr::select(celllinename, enst, dnamutation, aamutation, dnazygosity, rnazygosity)

  list(cellline.processedsequence = CCLE.mutations2)
}
