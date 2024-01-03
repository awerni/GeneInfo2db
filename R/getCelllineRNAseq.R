getCelllineRNAseq <- function(.splits = 20) {
  con <- getPostgresqlConnection()

  gene <- dplyr::tbl(con, "gene") |>
    dplyr::filter(species == "human") |>
    dplyr::collect()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  |>
    dplyr::filter(species == "human") |>
    dplyr::select(celllinename, depmap) |>
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # ------------------
  lab <- "Broad Institute"

  model_condition <- getFileData("OmicsDefaultModelConditionProfiles") |>
    dplyr::filter(ProfileType == "rna") |>
    left_join(getFileData("ModelCondition"), by = dplyr::join_by(ModelConditionID)) |>
    dplyr::select(-ProfileType, -ParentModelConditionID, -PassageNumber, -PlateCoating) |>
    dplyr::inner_join(cellline, by = dplyr::join_by(ModelID == depmap))

  #  --------- load TPMs ---------------------
  #expr_TPM <- getFileData("CCLE_expression_full")
  expr_TPM <- getFileData("OmicsExpressionAllGenesTPMLogp1Profile")
  colnames(expr_TPM) <- gsub("(^.*\\(|\\))", "", colnames(expr_TPM))

  if ("matrix" %in% class(expr_TPM)) {
    profile_ID <- rownames(expr_TPM)
    expr_TPM_long <- expr_TPM |>
      as.data.frame(stringsAsFactors = FALSE) |>
      tibble::rownames_to_column("rnaseqrunid") |>
      tidyr::pivot_longer(!rnaseqrunid, names_to = "ensg", values_to = "log2tpm")
  } else {
    profile_ID <- expr_TPM[[1]]

    expr_TPM_long <- expr_TPM |>
      dplyr::rename(rnaseqrunid = 1) |>
      tidyr::pivot_longer(!rnaseqrunid, names_to = "ensg", values_to = "log2tpm")
  }
  rm(expr_TPM)
  invisible(replicate(5, gc()))

  #  --------- load counts ---------------------
  #expr_counts <- getFileData("CCLE_RNAseq_reads")
  expr_counts <- getFileData("OmicsExpressionGenesExpectedCountProfile")
  colnames(expr_counts) <- gsub("(^.*\\(|\\))", "", colnames(expr_counts))

  if ("matrix" %in% class(expr_counts)) {
    expr_counts_long <- expr_counts |>
      as.data.frame(stringsAsFactors = FALSE) |>
      tibble::rownames_to_column("rnaseqrunid")
  } else {
    expr_counts_long <- expr_counts |>
      dplyr::rename(rnaseqrunid = 1)
  }
  rm(expr_counts)
  invisible(replicate(5, gc()))

  expr_counts_long <- expr_counts_long |>
    tidyr::pivot_longer(!rnaseqrunid, names_to = "ensg", values_to = "counts")  |>
    dplyr::mutate(counts = as.integer(counts))

  # --------------------------------------------
  rnaseqrun <- model_condition |>
    dplyr::select(rnaseqrunid = ProfileID, celllinename, growthmedia = FormulationID) |>
    dplyr::mutate(publish = TRUE, canonical = TRUE, rnaseqgroupid = 1, laboratory = lab)

  total_mem <- grep("total memory", system("vmstat -s -S M", intern = TRUE), value = TRUE)
  total_mem <- as.numeric(gsub("M total memory", "",total_mem))

  if (total_mem < 32000) {
    file_n <- 1
    allSplits <- split(profile_ID, cut(1:length(profile_ID), .splits))

    for (n in allSplits) {

      freeMemory <- gsub(grep("free memory", system("vmstat -s -S M", intern = TRUE), value = TRUE), pattern = " |(free memory)", replacement = "")
      log_trace("getCelllineRNAseq - split {file_n} - Free memory: {freeMemory}")
      expr_counts_long_set <- expr_counts_long |> dplyr::filter(rnaseqrunid %in% n)
      expr_TPM_long_set <- expr_TPM_long |> dplyr::filter(rnaseqrunid %in% n)

      depmap_RNAseq_set <- expr_counts_long_set |>
        dplyr::inner_join(expr_TPM_long_set, by = c("ensg", "rnaseqrunid")) |>
        dplyr::filter(ensg %in% gene$ensg & rnaseqrunid %in% rnaseqrun$rnaseqrunid)

      write_rds(depmap_RNAseq_set, useLocalFileRepo(paste0("tmp-depmap_RNAseq_set", file_n, ".rds")))
      file_n <- file_n + 1
      rm(expr_counts_long_set)
      rm(expr_TPM_long_set)
      rm(depmap_RNAseq_set)
      invisible(gc())
    }

    rm(expr_counts_long)
    rm(expr_TPM_long)
    invisible(replicate(3, gc()))

    allFiles <- dir(useLocalFileRepo(""), pattern = "tmp-depmap_RNAseq_set[0-9]+.rds", full.names = TRUE)
    depmap_RNAseq <- map_dfr(allFiles, readRDS)

    unlink(allFiles)
  } else {
    depmap_RNAseq <- expr_counts_long |>
      dplyr::inner_join(expr_TPM_long, by = c("ensg", "rnaseqrunid")) |>
      dplyr::filter(ensg %in% gene$ensg & rnaseqrunid %in% rnaseqrun$rnaseqrunid)
  }

  rnaseqgroup <- data.frame(
    rnaseqgroupid = 1,
    rnaseqname = 'untreated CCLE cellline reference set',
    processingpipeline = 'RNA-seq CCLE'
  )

  c(
    getLaboratory(lab),
    list(cellline.rnaseqgroup = rnaseqgroup,
         cellline.rnaseqrun = rnaseqrun,
         cellline.processedrnaseq = depmap_RNAseq)
  )
}