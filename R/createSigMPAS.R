# https://doi.org/10.1038/s41698-018-0051-4

# Note, that the original paper used unscaled expression values, here
# we are using log2-scaled values as expression input to the z-score
# normalization.

getSigMPASexpr <- function(sample_type) {
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
  
  if (sample_type == "cellline") {
  # load data for celllines
    sql1b <- paste0("SELECT rnaseqrunid, rr.celllinename, tumortype FROM cellline.rnaseqrun rr ",
                    "JOIN cellline.cellline c on c.celllinename = rr.celllinename ",
                    "WHERE tumortype NOT LIKE 'normal' AND canonical")
    sample_anno <- DBI::dbGetQuery(con, sql1b)
    
    sql2b <- paste0("SELECT ensg, rnaseqrunid, log2tpm FROM cellline.processedrnaseq ",
                    "WHERE rnaseqrunid IN ('", paste(sample_anno$rnaseqrunid, collapse = "','"), "')",
                    "AND ensg IN ('", paste( gene$ensg, collapse = "','"), "')")
  } else if (sample_type == "tissue") {
    # load data for tissues
    sql1b <- paste0("SELECT rnaseqrunid, rr.tissuename, tumortype FROM tissue.rnaseqrun rr ",
                    "JOIN tissue.tissue c on c.tissuename = rr.tissuename ",
                    "WHERE tumortype NOT LIKE 'normal' AND canonical")
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

createSigMPAS <- function(sample_data, tablename) {
  # calculate MPAS score
  res_MPAS <- sample_data$expr_long |>
    dplyr::group_by(ensg) |>
    dplyr::mutate(zscore = scale(log2tpm)[,1]) |>
    dplyr::ungroup() |>
    dplyr::group_by(rnaseqrunid) |>
    dplyr::summarise(MPAS = sum(zscore)/sqrt(length(sample_data$gene$symbol))) |>
    dplyr::inner_join(sample_data$sample_anno, by = "rnaseqrunid") |>
    dplyr::ungroup() |>
    dplyr::arrange(desc(MPAS)) |>
    dplyr::select(dplyr::ends_with("name"), score = MPAS) |>
    dplyr::mutate(signature = "MPAS")
  
  #check the distributions
  #ggplot(res_MPAS, aes(x = forcats::fct_reorder(tumortype, MPAS), y = MPAS)) + geom_boxplot() + coord_flip()
  
  signature_db <- data.frame(
    signature   = "MPAS",
    description = "Genentech 10 gene transcriptional MAPK Pathway Activity Score (MPAS)",
    unit        = "arbitrary units",
    hyperlink   = "https://doi.org/10.1038/s41698-018-0051-4"
  )
  
  ret <- c(checkGeneSignature(signature_db),
    list(dbtable = res_MPAS))
  
  names(ret)[names(ret) == "dbtable"] <- tablename
  ret
}

createCelllineSigMPAS <- function() {
  getSigMPASexpr("cellline") |> createSigMPAS("cellline.cellline2genesignature")
}

createTissueSigMPAS <- function() {
  getSigMPASexpr("tissue") |> createSigMPAS("tissue.tissue2genesignature")
}

