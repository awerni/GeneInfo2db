# https://elifesciences.org/articles/06498

getSigTP53expr <- function(sample_type) {
  con <- getPostgresqlConnection()
  
  sigSymbols <- c("MDM2", "CDKN1A", "ZMAT3", "DDB2", "FDXR", "RPS27L", "BAX", "RRM2B", "SESN1", "CCNG1", "XPC", "TNFRSF10B", "AEN")
  
  sql <- paste0("SELECT ensg, symbol FROM gene WHERE symbol IN ('", paste(sigSymbols, collapse = "', '"), "') ",
                "AND length(chromosome) <= 2")
  gene <- DBI::dbGetQuery(con, sql)
  
  missing <- setdiff(sigSymbols, gene$symbol)
  if (length(missing) > 0) logger::log_error(paste("symbols", paste(missing, collapse = ", "), "are missing"))
  
  # ------- load expression data -----
  if (sample_type == "cellline") {
    sql1b <- paste0("SELECT rnaseqrunid, rr.celllinename, tumortype FROM cellline.rnaseqrun rr ",
                    "JOIN cellline.cellline c on c.celllinename = rr.celllinename ",
                    "WHERE rnaseqgroupid IN (0,1) and canonical")
    sample_anno <- DBI::dbGetQuery(con, sql1b)
    sql2b <- paste0("SELECT ensg, rnaseqrunid, log2tpm FROM cellline.processedrnaseq ",
                    "WHERE rnaseqrunid IN ('", paste(sample_anno$rnaseqrunid, collapse = "','"), "')",
                    "AND ensg IN ('", paste( gene$ensg, collapse = "','"), "')")
    
  } else if (sample_type == "tissue") {
    sql1b <- paste0("SELECT rnaseqrunid, rr.tissuename, tumortype FROM tissue.rnaseqrun rr ",
                    "JOIN tissue.tissue c on c.tissuename = rr.tissuename ",
                    "WHERE rnaseqgroupid IN (0,1) and canonical")
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
  
calcNIBR_TP53 <- function(sample_data, tablename) {
  # ----------- calc NIBR_TP53 ------------
  expr_mean <- sample_data$expr_long |>
    dplyr::group_by(ensg) |>
    dplyr::summarise(log2tpm_mean = mean(log2tpm),
                     log2tpm_sd = sd(log2tpm))
    
  res_TP53 <- sample_data$expr_long |>
    dplyr::inner_join(expr_mean, by = "ensg") |>
    dplyr::mutate(log2tpm_z = (log2tpm - log2tpm_mean)/log2tpm_sd) |>
    dplyr::group_by(rnaseqrunid) |>
    dplyr::summarise(score = sum(log2tpm_z)) |>
    dplyr::inner_join(sample_data$sample_anno, by = "rnaseqrunid") |>
    dplyr::select(dplyr::ends_with("name"), score) |>
    dplyr::mutate(signature = "NIBR_TP53")
  
  signature_db <- data.frame(
    signature = "NIBR_TP53",
    description = "Novartis 13 Gene TP53 Target Gene Signature", 
    unit = "arbitrary units", 
    hyperlink = "https://elifesciences.org/articles/06498"
  )
  
  ret <- c(checkGeneSignature(signature_db),
    list(dbtable = res_TP53))
  
  names(ret)[names(ret) == "dbtable"] <- tablename
  ret
}

createCelllineSigTP53 <- function() {
  getSigTP53expr("cellline") |> calcNIBR_TP53("cellline.cellline2genesignature")
}

createTissueSigTP53 <- function() {
  getSigTP53expr("tissue") |> calcNIBR_TP53("tissue.tissue2genesignature")
}