# https://www.nature.com/articles/s41591-018-0302-5
createCelllineSigIFN <- function() {

  con <- getPostgresqlConnection()

  sig_NIBR_IFN <- c("ADAR","DDX60","HERC6","IRF7","OASL","PSME2","STAT2","TRIM25","BST2","DHX58",
                    "IFI35","ISG15","OGFR","RSAD2","TDRD7","UBE2L6","CASP1","EIF2AK2","IFIH1","ISG20",
                    "PARP12","RTP4","TRAFD1","USP18","CMPK2","EPSTI1","IFIT2","MX1","PARP14","SAMD9L",
                    "TRIM14","CXCL10","GBP4","IFIT3","NMI","PNPT1","SP110","TRIM21") %>% unique()

  sql <- paste0("SELECT ensg, symbol FROM gene WHERE symbol IN ('",
                paste(sig_NIBR_IFN, collapse = "','"), "') AND species = 'human'",
                "AND length(chromosome) <= 2")

  gene <- DBI::dbGetQuery(con, sql)
  missing <- setdiff(sig_NIBR_IFN, gene$symbol)
  if (length(missing) > 0) stop("symbols ", paste(missing, collapse = ", "), " are missing")

  # ------------ load data for celllines -----

  sql1b <- paste0("SELECT rnaseqrunid, rr.celllinename, tumortype, morphology FROM cellline.rnaseqrun rr ",
                 "JOIN cellline.cellline c on c.celllinename = rr.celllinename ",
                 "WHERE rnaseqgroupid IN (0,1) and canonical")
  cellline_anno <- DBI::dbGetQuery(con, sql1b)

  sql2b <- paste0("SELECT ensg, rnaseqrunid, log2tpm FROM cellline.processedrnaseq ",
                 "WHERE rnaseqrunid IN ('", paste(cellline_anno$rnaseqrunid, collapse = "','"), "')",
                 "AND ensg IN ('", paste( gene$ensg, collapse = "','"), "')")
  expr_long_cl <- DBI::dbGetQuery(con, sql2b)

  RPostgres::dbDisconnect(con)

  expr_cl <- expr_long_cl %>%
    tidyr::pivot_wider(rnaseqrunid, names_from = "ensg", values_from = "log2tpm") %>%
    tibble::column_to_rownames("rnaseqrunid")

  # ----------- calc NIBR_IFN ------------
  calcNIBR_IFN <- function(expr4calc, expr4norm) {
    ymedian <- apply(expr4norm, 2, median)
    ymad    <- apply(expr4norm, 2, mad)
    dataz <- t((t(expr4calc) - ymedian)/ymad)
    data.frame(rnaseqrunid = rownames(expr4calc), NIBR_IFN = apply(dataz, 1, mean))
  }

  rsid_cl <- cellline_anno %>%
    dplyr::filter(!grepl("fibroblast", morphology)) %>%
    .$rnaseqrunid

  res_NIBR_IFN_cl <- calcNIBR_IFN(expr_cl, expr_cl[rsid_cl, ]) %>%
    dplyr::inner_join(cellline_anno, by = "rnaseqrunid")

  # ---------- check distribution --------------
  #ggplot(res_NIBR_IFN_cl, aes(x = forcats::fct_reorder(tumortype, NIBR_IFN), y = NIBR_IFN)) + geom_boxplot() + coord_flip()

  # ---------------- prepare return values -------

  res_import_cl <- res_NIBR_IFN_cl %>%
    dplyr::select(celllinename, score = NIBR_IFN) %>%
    dplyr::mutate(signature = "NIBR_IFN")

  signature_db <- data.frame(
    signature = "NIBR_IFN",
    description = "Novartis 38 Gene Interferon activity signature",
    unit = "arbitrary units",
    hyperlink = "https://www.nature.com/articles/s41591-018-0302-5"
  )

  list(public.genesignature = signature_db,
       cellline.cellline2genesignature = res_import_cl)

}
