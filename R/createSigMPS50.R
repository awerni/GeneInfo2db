getSigMPS50expr <- function(sample_type) {
  con <- getPostgresqlConnection()
  
  sigSymbols <- c("ACSM1", "AMACR", "APOC1", "ARLNC1", "B3GNT6", "CAMKK2", 
                  "COL9A2", "CRISP3", "CST2", "CYB561A3", "DLX1", "EEF1A2",
                  "ETV1", "F5", "GDF15", "GLYATL1", "GOLM1", "GRIN3A",
                  "HPN", "LBH", "LINC00993", "LRRN1", "MIPEP", "MS4A8",
                  "MYO6", "NKAIN1", "NUDT8", "OR51E2", "PCA3", "PCAT14",
                  "PCGEM1", "PDLIM5", "PEX10", "PLA1A", "PLA2G7", "SCHLAP1",
                  "SPON2", "TDO2", "TFF3", "TK1", "TMEFF2", "TMSB15A",
                  "TRGV9", "VSTM2L")
  
  sql <- paste0("SELECT ensg, symbol FROM gene WHERE symbol IN ('", paste(sigSymbols, collapse = "', '"), "') ",
                "AND length(chromosome) <= 2")
  gene <- DBI::dbGetQuery(con, sql)
  
  missing <- setdiff(sigSymbols, gene$symbol)
  if (length(missing) > 0) logger::log_error(paste("symbols", paste(missing, collapse = ", "), "are missing"))
  
  # ------- load expression data -----
  if (sample_type == "cellline") {
    sql1b <- paste0("SELECT rnaseqrunid, rr.celllinename, tumortype FROM cellline.rnaseqrun rr ",
                    "JOIN cellline.cellline c on c.celllinename = rr.celllinename ",
                    "WHERE rnaseqgroupid IN (1) and canonical AND tumortype = 'prostate cancer'")
    sample_anno <- DBI::dbGetQuery(con, sql1b)
    sql2b <- paste0("SELECT ensg, rnaseqrunid, log2tpm FROM cellline.processedrnaseq ",
                    "WHERE rnaseqrunid IN ('", paste(sample_anno$rnaseqrunid, collapse = "','"), "')",
                    "AND ensg IN ('", paste( gene$ensg, collapse = "','"), "')")
    
  } else if (sample_type == "tissue") {
    sql1b <- paste0("SELECT rnaseqrunid, rr.tissuename, tumortype FROM tissue.rnaseqrun rr ",
                    "JOIN tissue.tissue c on c.tissuename = rr.tissuename ",
                    "WHERE rnaseqgroupid IN (1, 2) and canonical AND organ like 'Prostate%';")
    sample_anno <- DBI::dbGetQuery(con, sql1b)
    sql2b <- paste0("SELECT ensg, rnaseqrunid, log2tpm FROM tissue.processedrnaseq ",
                    "WHERE rnaseqrunid IN ('", paste(sample_anno$rnaseqrunid, collapse = "','"), "')",
                    "AND ensg IN ('", paste( gene$ensg, collapse = "','"), "')")
  } else {
    logger::log_error("invalid sample type")
  }
  
  expr_long <- DBI::dbGetQuery(con, sql2b)
  RPostgres::dbDisconnect(con)
  
  return(list(sample_anno = sample_anno,
              expr_long = expr_long,
              gene = gene))
}

calcMPS50 <- function(sample_data, tablename) {
  # ----------- calc MPS50 ------------
  expr_mean <- sample_data$expr_long |>
    dplyr::group_by(ensg) |>
    dplyr::summarise(log2tpm_mean = mean(log2tpm),
                     log2tpm_sd = sd(log2tpm))
  
  res_MPS50 <- sample_data$expr_long |>
    dplyr::inner_join(expr_mean, by = "ensg") |>
    dplyr::mutate(log2tpm_z = (log2tpm - log2tpm_mean)/log2tpm_sd) |>
    dplyr::group_by(rnaseqrunid) |>
    dplyr::summarise(score = sum(log2tpm_z)) |>
    dplyr::inner_join(sample_data$sample_anno, by = "rnaseqrunid") |>
    dplyr::select(dplyr::ends_with("name"), score) |>
    dplyr::mutate(signature = "MPS50")
  
  signature_db <- data.frame(
    signature = "MPS50",
    description = "MPS50 Prostate Fusion Gene Signature", 
    unit = "arbitrary units", 
    hyperlink = "https://doi.org/10.1016/j.clgc.2015.12.001"
  )
  
  ret <- c(checkGeneSignature(signature_db),
           list(dbtable = res_MPS50))
  
  names(ret)[names(ret) == "dbtable"] <- tablename
  ret
}

createCelllineSigMPS50 <- function() {
  getSigMPS50expr("cellline") |> calcMPS50("cellline.cellline2genesignature")
}

createTissueSigMPS50 <- function() {
  getSigMPS50expr("tissue") |> calcMPS50("tissue.tissue2genesignature")
}