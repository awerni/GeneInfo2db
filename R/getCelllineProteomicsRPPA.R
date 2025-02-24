#' @export
getCelllineProteomicsRPPA <- function() {

  con <- getPostgresqlConnection()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  |>
    dplyr::filter(species == "human") |>
    dplyr::select(celllinename, depmap) |>
    dplyr::collect()

  gene <- dplyr::tbl(con, "gene") |>
    dplyr::filter(species == "human") |>
    dplyr::filter(nchar(chromosome) < 3) |>
    dplyr::select(ensg, symbol) |>
    dplyr::filter(!is.na(symbol)) |>
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # -------------------------

  ab_anno <- getFileData('CCLE_RPPA_Ab_info_20181226') |>
    dplyr::mutate(Antibody_Name = gsub("_Caution", "", Antibody_Name))

  ab_anno_gene <- ab_anno |>
    dplyr::select(Antibody_Name, Target_Genes) |>
    tidyr::separate_rows(Target_Genes, sep = " ") |>
    dplyr::rename(symbol = Target_Genes) |> mutate(symbol = toupper(symbol)) |>
    dplyr::mutate(symbol = gsub("MRE11A", "MRE11", symbol)) |>
    dplyr::mutate(symbol = gsub("C12ORF5", "TIGAR", symbol))

  symbol_ensg <- gene |>
    dplyr::filter(symbol %in% ab_anno_gene$symbol)

  ab_anno_gene <- ab_anno_gene |>
    dplyr::left_join(symbol_ensg, by = "symbol") |>
    dplyr::select(-symbol) |>
    dplyr::rename(antibody = Antibody_Name)

  ab_anno <- ab_anno |>
    dplyr::select(-Target_Genes) |>
    dplyr::rename(vendor = Company, antibody = Antibody_Name, validation_status = Validation_Status, catalog_number = Catalog_Number)

  ab_data <- getFileData('CCLE_RPPA_20181003')

  if ("matrix" %in% class(ab_data)) {
    ab_data_long <- ab_data |>
      as.data.frame() |>
      tibble::rownames_to_column("depmap") |>
      dplyr::inner_join(cellline, by = "depmap") |>
      dplyr::select(-depmap) |>
      tidyr::pivot_longer(!celllinename, names_to = "antibody", values_to = "score") |>
      dplyr::mutate(antibody = gsub("_Caution", "", antibody))
  } else {
    ab_data_long <- ab_data |>
      dplyr::rename(celllinename = 1) |>
      dplyr::filter(celllinename %in% cellline$celllinename) |>
      tidyr::pivot_longer(!celllinename, names_to = "antibody", values_to = "score") |>
      dplyr::mutate(antibody = gsub("_Caution", "", antibody))
  }

  list(public.antibody = ab_anno,
       public.gene2antibody = ab_anno_gene,
       cellline.processedproteinexpression = ab_data_long)
}
