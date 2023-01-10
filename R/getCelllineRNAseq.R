getCelllineRNAseq <- function(.splits = 20) {
  con <- getPostgresqlConnection()

  gene <- dplyr::tbl(con, "gene") %>%
    dplyr::filter(species == "human") %>%
    dplyr::collect()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::collect()

  laboratory <- dplyr::tbl(con, "laboratory") %>%
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  # ------------------
  lab <- "Broad Institute"

  #expr_TPM <- getFileData("OmicsExpressionProteinCodingGenesTPMLogp1")
  expr_TPM <- getFileData("CCLE_expression_full")
  colnames(expr_TPM) <- gsub("(^.*\\(|\\))", "", colnames(expr_TPM))

  if ("matrix" %in% class(expr_TPM)) {
    depmap_ID <- rownames(expr_TPM)
    expr_TPM_long <- expr_TPM %>%
      as.data.frame(stringsAsFactors = FALSE) %>%
      tibble::rownames_to_column("rnaseqrunid") %>%
      tidyr::pivot_longer(!rnaseqrunid, names_to = "ensg", values_to = "log2tpm")
  } else {
    depmap_ID <- expr_TPM[[1]]
    #expr_TPM_long <- expr_TPM %>%
    #  dplyr::rename(rnaseqrunid = 1) %>%
    #  tidyr::gather(key = "ensg", value = "log2tpm", -rnaseqrunid)

    expr_TPM_long <- expr_TPM %>%
      dplyr::rename(rnaseqrunid = 1) %>%
      tidyr::pivot_longer(!rnaseqrunid, names_to = "ensg", values_to = "log2tpm")
  }
  rm(expr_TPM)
  invisible(replicate(5, gc()))

  expr_counts <- getFileData("CCLE_RNAseq_reads")
  colnames(expr_counts) <- gsub("(^.*\\(|\\))", "", colnames(expr_counts))

  if ("matrix" %in% class(expr_counts)) {
    expr_counts_long <- expr_counts %>%
      as.data.frame(stringsAsFactors = FALSE) %>%
      tibble::rownames_to_column("rnaseqrunid")
  } else {
    expr_counts_long <- expr_counts %>%
      dplyr::rename(rnaseqrunid = 1)
  }
  rm(expr_counts)
  invisible(replicate(5, gc()))

  expr_counts_long <- expr_counts_long %>%
    tidyr::gather(key = "ensg", value = "counts", -rnaseqrunid) %>%
    #tidyr::pivot_longer(!rnaseqrunid, names_to = "ensg", values_to = "counts")  %>%
    dplyr::mutate(counts = as.integer(counts))

  rnaseqrun <- cellline %>%
    dplyr::select(rnaseqrunid = depmap, celllinename) %>%
    dplyr::filter(rnaseqrunid %in% depmap_ID) %>%
    dplyr::mutate(publish = TRUE, canonical = TRUE, rnaseqgroupid = 1, laboratory = lab)

  total_mem <- grep("total memory", system("vmstat -s -S M", intern = TRUE), value = TRUE)
  total_mem <- as.numeric(gsub("M total memory", "",total_mem))

  if (total_mem < 32000) {
    file_n <- 1
    allSplits <- split(depmap_ID, cut(1:length(depmap_ID), .splits))

    for (n in allSplits) {

      freeMemory <- gsub(grep("free memory", system("vmstat -s -S M", intern = TRUE), value = TRUE), pattern = " |(free memory)", replacement = "")
      log_trace("getCelllineRNAseq - split {file_n} - Free memory: {freeMemory}")
      expr_counts_long_set <- expr_counts_long %>% dplyr::filter(rnaseqrunid %in% n)
      expr_TPM_long_set <- expr_TPM_long %>% dplyr::filter(rnaseqrunid %in% n)

      CCLE.RNAseq_set <- expr_counts_long_set %>%
        dplyr::inner_join(expr_TPM_long_set, by = c("ensg", "rnaseqrunid")) %>%
        dplyr::filter(ensg %in% gene$ensg & rnaseqrunid %in% rnaseqrun$rnaseqrunid)

      write_rds(CCLE.RNAseq_set, useLocalFileRepo(paste0("tmp-CCLE.RNAseq_set", file_n, ".rds")))
      file_n <- file_n + 1
      rm(expr_counts_long_set)
      rm(expr_TPM_long_set)
      rm(CCLE.RNAseq_set)
      invisible(gc())
    }

    rm(expr_counts_long)
    rm(expr_TPM_long)
    invisible(replicate(10, gc()))


    allFiles <- dir(useLocalFileRepo(""), pattern = "tmp-CCLE.RNAseq_set[0-9]+.rds", full.names = TRUE)
    CCLE.RNAseq <- map_dfr(allFiles, readRDS)

    unlink(allFiles)
  } else {
    CCLE.RNAseq <- expr_counts_long %>%
      dplyr::inner_join(expr_TPM_long, by = c("ensg", "rnaseqrunid")) %>%
      dplyr::filter(ensg %in% gene$ensg & rnaseqrunid %in% rnaseqrun$rnaseqrunid)
  }

  rnaseqgroup <- data.frame(
    rnaseqgroupid = 1,
    rnaseqname = 'untreated CCLE cellline reference set',
    processingpipeline = 'RNA-seq CCLE'
  )

  if (lab %in% laboratory$laboratory) {
    list(cellline.rnaseqgroup = rnaseqgroup,
         cellline.rnaseqrun = rnaseqrun,
         cellline.processedrnaseq = CCLE.RNAseq)
  } else {
    list(public.laboratory = data.frame(laboratory = lab),
         cellline.rnaseqgroup = rnaseqgroup,
         cellline.rnaseqrun = rnaseqrun,
         cellline.processedrnaseq = CCLE.RNAseq)
  }
}
