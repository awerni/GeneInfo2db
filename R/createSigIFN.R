# https://www.nature.com/articles/s41591-018-0302-5

getSigIFNexpr <- function(sample_type) {

  con <- getPostgresqlConnection()

  sig_NIBR_IFN <- c("ADAR", "DDX60", "HERC6", "IRF7", "OASL", "PSME2", "STAT2", "TRIM25", "BST2", "DHX58",
                    "IFI35", "ISG15", "OGFR", "RSAD2", "TDRD7", "UBE2L6", "CASP1", "EIF2AK2", "IFIH1", "ISG20",
                    "PARP12", "RTP4", "TRAFD1", "USP18", "CMPK2", "EPSTI1", "IFIT2", "MX1", "PARP14", "SAMD9L",
                    "TRIM14", "CXCL10", "GBP4", "IFIT3", "NMI", "PNPT1", "SP110", "TRIM21") %>% unique()

  sql <- paste0("SELECT ensg, symbol FROM gene WHERE symbol IN ('",
                paste(sig_NIBR_IFN, collapse = "','"), "') AND species = 'human'",
                "AND length(chromosome) <= 2")

  gene <- DBI::dbGetQuery(con, sql)
  missing <- setdiff(sig_NIBR_IFN, gene$symbol)
  if (length(missing) > 0) stop("symbols ", paste(missing, collapse = ", "), " are missing")

  if (sample_type == "cellline") {
    # load data for celllines
    sql1b <- paste0("SELECT rnaseqrunid, rr.celllinename, tumortype, morphology FROM cellline.rnaseqrun rr ",
                    "JOIN cellline.cellline c on c.celllinename = rr.celllinename ",
                    "WHERE rnaseqgroupid = 1 and canonical")
    sample_anno <- DBI::dbGetQuery(con, sql1b)
    sql2b <- paste0("SELECT ensg, rnaseqrunid, log2tpm FROM cellline.processedrnaseq ",
                    "WHERE rnaseqrunid IN ('", paste(sample_anno$rnaseqrunid, collapse = "','"), "')",
                    "AND ensg IN ('", paste( gene$ensg, collapse = "','"), "')")
  } else if (sample_type == "tissue") {
    sql1b <- paste0("SELECT rnaseqrunid, rr.tissuename, tumortype FROM tissue.rnaseqrun rr ",
                    "JOIN tissue.tissue c on c.tissuename = rr.tissuename ",
                    "WHERE rnaseqgroupid IN (1, 2) and canonical")
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

calculateSigIFN <- function(sample_data, tablename) {

  expr <- sample_data$expr_long %>%
    tidyr::pivot_wider(id_cols = rnaseqrunid, names_from = "ensg", values_from = "log2tpm") %>%
    tibble::column_to_rownames("rnaseqrunid")

  # ----------- calc NIBR_IFN ------------
  calcNIBR_IFN <- function(expr4calc, expr4norm) {
    ymedian <- apply(expr4norm, 2, median)
    ymad    <- apply(expr4norm, 2, mad)
    dataz <- t((t(expr4calc) - ymedian)/ymad)
    data.frame(rnaseqrunid = rownames(expr4calc), NIBR_IFN = apply(dataz, 1, mean))
  }

  if (("celllinename" %in% colnames(sample_data$sample_anno))) {
    rsid_cl <- sample_data$sample_anno %>%
      dplyr::filter(!grepl("fibroblast", morphology)) %>%
      pull("rnaseqrunid")
  } else {
    rsid_cl <- sample_data$sample_anno$rnaseqrunid
  }

  res_NIBR_IFN <- calcNIBR_IFN(expr, expr[rsid_cl, ]) %>%
    dplyr::inner_join(sample_data$sample_anno, by = "rnaseqrunid")

  # ---------- check distribution --------------
  #ggplot(res_NIBR_IFN, aes(x = forcats::fct_reorder(tumortype, NIBR_IFN), y = NIBR_IFN)) + 
  #  geom_boxplot() + coord_flip()

  res_import <- res_NIBR_IFN %>%
    dplyr::select(dplyr::ends_with("name"), score = NIBR_IFN) %>%
    dplyr::mutate(signature = "NIBR_IFN")

  signature_db <- data.frame(
    signature = "NIBR_IFN",
    description = "Novartis 38 Gene Interferon activity signature",
    unit = "arbitrary units",
    hyperlink = "https://www.nature.com/articles/s41591-018-0302-5"
  )

  sig <- c(checkGeneSignature(signature_db),
    list(dbtable = res_import))
  
  names(sig)[names(sig) == "dbtable"] <- tablename
  sig
}

#' @export
createCelllineSigIFN <- function() {
  getSigIFNexpr("cellline") |> calculateSigIFN("cellline.cellline2genesignature")
}

#' @export
createTissueSigIFN <- function() {
  getSigIFNexpr("tissue") |> calculateSigIFN("tissue.tissue2genesignature")
}