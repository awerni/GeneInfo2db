# https://elifesciences.org/articles/06498
createSigTP53 <- function() {

  con <- getPostgresqlConnection()
  
  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename) %>%
    dplyr::collect()
  
  alternative_celllinename <- dplyr::tbl(con, dbplyr::in_schema("cellline", "alternative_celllinename"))  %>%
    dplyr::select(celllinename, alternative_celllinename) %>%
    dplyr::collect()
  
  sigSymbols <- c("MDM2", "CDKN1A", "ZMAT3", "DDB2", "FDXR", "RPS27L", "BAX", "RRM2B", "SESN1", "CCNG1", "XPC", "TNFRSF10B", "AEN")
  
  sql <- paste0("SELECT ensg, symbol FROM gene WHERE symbol IN ('", paste(sigSymbols, collapse = "', '"), "') ",
                "AND length(chromosome) <= 2")
  gene <- DBI::dbGetQuery(con, sql)
  
  missing <- setdiff(sigSymbols, gene$symbol)
  if (length(missing) > 0) stop("symbols ", paste(missing, collapse = ", "), " are missing")
  
  # ------- load expression data -----
  
  sql1b <- paste0("SELECT rnaseqrunid, rr.celllinename, tumortype FROM cellline.rnaseqrun rr ",
                 "JOIN cellline.cellline c on c.celllinename = rr.celllinename ",
                 "WHERE rnaseqgroupid IN (0,1) and canonical")
  cellline_anno <- DBI::dbGetQuery(con, sql1b)
  
  sql2b <- paste0("SELECT ensg, rnaseqrunid, log2tpm FROM cellline.processedrnaseq ",
                 "WHERE rnaseqrunid IN ('", paste(cellline_anno$rnaseqrunid, collapse = "','"), "')",
                 "AND ensg IN ('", paste( gene$ensg, collapse = "','"), "')")
  expr_long_cl <- DBI::dbGetQuery(con, sql2b)
  
  # ----------- calc NIBR_TP53 ------------
  
  calcNIBR_TP53 <- function(expr) {
    
    expr_mean <- expr %>%
      group_by(ensg) %>%
      summarise(log2tpm_mean = mean(log2tpm),
                log2tpm_sd = sd(log2tpm))
    
    expr %>%
      inner_join(expr_mean, by = "ensg") %>%
      mutate(log2tpm_z = (log2tpm - log2tpm_mean)/log2tpm_sd) %>%
      group_by(rnaseqrunid) %>%
      summarise(score = sum(log2tpm_z))
  }
  
  res_NIBR_TP53_cl <- calcNIBR_TP53(expr_long_cl) %>%
    inner_join(cellline_anno, by = "rnaseqrunid")
  
  # ---------- check distribution --------------
  # sql3 <- paste0("select celllinename, coarse(aamutation) AS tp53_coarse ",
  #                "from cellline.processedsequenceextended WHERE symbol = 'TP53'")
  # mut_anno <-  DBI::dbGetQuery(con, sql3)
  # 
  # res_NIBR_TP53_cl2 <- res_NIBR_TP53_cl %>%
  #   left_join(mut_anno, by = "celllinename")
  # 
  # ggplot(res_NIBR_TP53_cl2, aes(x = tumortype, y = score)) + geom_boxplot() + facet_wrap(~tp53_coarse) + geom_hline(yintercept = 0) +  coord_flip()

  RPostgres::dbDisconnect(con)
  
  res_import_cl <- res_NIBR_TP53_cl %>% 
    dplyr::select(celllinename, score) %>% 
    mutate(signature = "NIBR_TP53")
  
  signature_db <- data.frame(
    signature = "NIBR_TP53",
    description = "Novartis 13 Gene TP53 Target Gene Signature", 
    unit = "arbitrary units", 
    hyperlink = "https://elifesciences.org/articles/06498"
  )

  list(public.genesignature = signature_db,
       cellline.cellline2genesignature = res_import_cl)
    
}