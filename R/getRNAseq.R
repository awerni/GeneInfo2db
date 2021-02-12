getRNAseq <- function() {
  con <- getPostgresqlConnection()
  
  gene <- dplyr::tbl(con, "gene") %>%
    dplyr::filter(species == "human") %>%
    dplyr::collect()
  
  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>% 
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)

  # ------------------  
  expr_TPM <- getFileData("CCLE_expression_full")
  colnames(expr_TPM) <- gsub("(^.*\\(|\\))", "", colnames(expr_TPM))
  
  expr_TPM_long <- expr_TPM %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    tibble::rownames_to_column("rnaseqrunid") %>%
    tidyr::pivot_longer(!rnaseqrunid, names_to = "ensg", values_to = "log2tpm")
  
  depmap_ID <- rownames(expr_TPM)
  rm(expr_TPM)
  
  expr_counts_long <- getFileData("CCLE_RNAseq_reads") %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    tibble::rownames_to_column("rnaseqrunid") %>%
    tidyr::pivot_longer(!rnaseqrunid, names_to = "ensg", values_to = "counts")  %>%
    dplyr::mutate(ensg = gsub("\\)", "", gsub("^.*\\(", "", ensg)),
                  counts = as.integer(counts))
  
  rnaseqrun <- cellline %>%
    dplyr::select(rnaseqrunid = depmap, celllinename) %>%
    dplyr::filter(rnaseqrunid %in% depmap_ID) %>%
    dplyr::mutate(publish = TRUE, canonical = TRUE, rnaseqgroupid = 1, laboratory = 'Broad Institute')
  
  total_mem <- grep("total memory", system("vmstat -s -S M", intern = TRUE), value = TRUE)
  total_mem <- as.numeric(gsub("M total memory", "",total_mem))
                    
  if (total_mem < 32000) {
    file_n <- 1
    for (n in split(depmap_ID, cut(1:length(depmap_ID), 3))) {
      expr_counts_long_set <- expr_counts_long %>% filter(rnaseqrunid %in% n)
      expr_TPM_long_set <- expr_TPM_long %>% filter(rnaseqrunid %in% n)
  
      CCLE.RNAseq_set <- expr_counts_long_set %>%
        dplyr::inner_join(expr_TPM_long_set, by = c("ensg", "rnaseqrunid")) %>%
        dplyr::filter(ensg %in% gene$ensg & rnaseqrunid %in% rnaseqrun$rnaseqrunid)
  
      write_rds(CCLE.RNAseq_set, paste0("CCLE.RNAseq_set", file_n, ".rds"))
      file_n <- file_n + 1
      rm(expr_counts_long_set)
      rm(expr_TPM_long_set)
      rm(CCLE.RNAseq_set)
    }
  
    CCLE.RNAseq <- bind_rows(read_rds("CCLE.RNAseq_set1.rds"),
                             read_rds("CCLE.RNAseq_set2.rds"),
                             read_rds("CCLE.RNAseq_set3.rds"))
  
    file.remove("CCLE.RNAseq_set1.rds")
    file.remove("CCLE.RNAseq_set2.rds")
    file.remove("CCLE.RNAseq_set3.rds")
  } else {    
    CCLE.RNAseq <- expr_counts_long %>%
      inner_join(expr_TPM_long, by = c("ensg", "rnaseqrunid")) %>%
      filter(ensg %in% genes$ensg & rnaseqrunid %in% rnaseqrun$rnaseqrunid)
    
    rm(expr_counts_long_set)
    rm(expr_TPM_long_set)
  }

  rnaseqgroup <- data.frame(
    rnaseqgroupid = 1,
    rnaseqname = 'untreated CCLE cellline reference set',
    processingpipeline = 'RNA-seq CCLE'
  )
  
  list(public.laboratory = data.frame(laboratory = 'Broad Institute'),
       cellline.rnaseqgroup = rnaseqgroup,
       cellline.rnaseqrun = rnaseqrun, 
       cellline.processedrnaseq = CCLE.RNAseq)
  
}