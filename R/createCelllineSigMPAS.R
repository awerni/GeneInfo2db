# https://doi.org/10.1038/s41698-018-0051-4

# Note, that the original paper used unscaled expression values, here 
# we are using log2-scaled values as expression input to the z-score 
# normalization.

createCelllineSigMPAS <- function() {

  sig_MPAS <- c("CCND1", "DUSP4", "DUSP6", "EPHA2", "EPHA4", "ETV4", "ETV5", "PHLDA1", "SPRY2", "SPRY4")

  con <- getPostgresqlConnection()
  
  sql1 <- paste0("SELECT ensg, symbol FROM gene WHERE symbol IN ('", 
                paste(sig_MPAS, collapse = "','"), "') AND species = 'human'",
                "AND length(chromosome) <= 2")
  
  gene <- DBI::dbGetQuery(con, sql1)
  missing <- setdiff(sig_MPAS, gene$symbol)
  
  if (length(missing) > 0) stop("Symbols ", paste(missing, collapse = ", "), " are missing")
  
  if (length(gene$symbol) != length(sig_MPAS)) {
    stop("Signature contains ", length(sig_MPAS), 
         " genes, while the mapping contains ", length(gene), " genes")
  }
  
  # load data for celllines
  sql1b <- paste0("SELECT rnaseqrunid, rr.celllinename, tumortype FROM cellline.rnaseqrun rr ",
                  "JOIN cellline.cellline c on c.celllinename = rr.celllinename ",
                  "WHERE tumortype NOT LIKE 'normal'")
  cellline_anno <- DBI::dbGetQuery(con, sql1b)
  
  sql2b <- paste0("SELECT ensg, rnaseqrunid, log2tpm FROM cellline.processedrnaseq ",
                  "WHERE rnaseqrunid IN ('", paste(cellline_anno$rnaseqrunid, collapse = "','"), "')",
                  "AND ensg IN ('", paste( gene$ensg, collapse = "','"), "')")
  expr_long_cl <- DBI::dbGetQuery(con, sql2b)
  
  RPostgres::dbDisconnect(con)
  
  # calculate MPAS score
  res_MPAS_cl <- expr_long_cl %>% 
    group_by(ensg) %>% 
    mutate(zscore = scale(log2tpm)[,1]) %>% 
    group_by(rnaseqrunid) %>% 
    mutate(MPAS = sum(zscore)/sqrt(length(gene$symbol))) %>% 
    inner_join(cellline_anno, by = "rnaseqrunid") %>% 
    distinct(celllinename, tumortype, MPAS) %>% 
    ungroup() %>%
    arrange(desc(MPAS))
  
  # look at the distributions
  #ggplot(res_MPAS_cl, aes(x = forcats::fct_reorder(tumortype, MPAS), y = MPAS)) + geom_boxplot() + coord_flip()
  
  res_import_cl <- res_MPAS_cl %>% 
    select(celllinename, score = MPAS) %>% 
    mutate(signature = "MPAS")
  
  signature_db <- data.frame(
    signature   = "MPAS",
    description = "Genentech 10 gene transcriptional MAPK Pathway Activity Score (MPAS)", 
    unit        = "arbitrary units", 
    hyperlink   = "https://doi.org/10.1038/s41698-018-0051-4"
  )
  
  list(public.genesignature = signature_db,
       cellline.cellline2genesignature = res_import_cl)
  
}
