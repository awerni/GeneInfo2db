getCellline_CRISPR_screen <- function(screen_name, screen_desc, file_essentials,
                              file_nonessentials, file_effect,
                              file_effect_unscaled, file_dependency,
                              splits = 50) {
  
  con <- getPostgresqlConnection()
  
  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  %>%
    dplyr::filter(species == "human") %>%
    dplyr::select(celllinename, depmap) %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  # -------------------------
  calc_unscaled_to_old_ceres <- function() {
    
    essential.genes <- getFileData(file_essentials)
    nonessential.genes <- getFileData(file_nonessentials)
    
    gene_effect_unscaled <- getFileData(file_effect_unscaled)  
    
    if ("matrix" %in% class(gene_effect_unscaled)) {
      gene_effect_unscaled <- gene_effect_unscaled %>%
        as.data.frame() %>%
        tibble::rownames_to_column("depmap")
    } else {
      gene_effect_unscaled <- gene_effect_unscaled %>%
        dplyr::rename(depmap = 1)
    }
    
    gene_effect_unscaled <- gene_effect_unscaled %>%
      tidyr::pivot_longer(!depmap, names_to = "gene", values_to = "ceres_unscaled")
    
    # calc median ceres_unscaled per sample for nonessetial genes
    nonessential_median <- gene_effect_unscaled %>% 
      dplyr::filter(gene %in% nonessential.genes$gene) %>%
      dplyr::group_by(depmap) %>%
      dplyr::summarise(ceres_nonessential_unscaled_median = median(ceres_unscaled, na.rm = TRUE))
    
    # shift ceres_unscaled by median of the nonessential genes, then calc median ceres_unscaled per sample for essetial genes
    common.essentials_median <- gene_effect_unscaled %>% 
      dplyr::filter(gene %in% essential.genes$gene) %>%
      dplyr::inner_join(nonessential_median, by = "depmap") %>%
      dplyr::mutate(ceres_shifted = ceres_unscaled - ceres_nonessential_unscaled_median) %>%
      dplyr::group_by(depmap) %>%
      dplyr::summarise(ceres_common.essentials_shifted_median = median(ceres_shifted, na.rm = TRUE))
    
    gene_effect_unscaled %>%
      dplyr::inner_join(nonessential_median, by = "depmap") %>%
      dplyr::inner_join(common.essentials_median, by = "depmap") %>%
      dplyr::mutate(ceres = (ceres_unscaled - ceres_nonessential_unscaled_median)/abs(ceres_common.essentials_shifted_median)) %>%
      dplyr::select(-ceres_nonessential_unscaled_median, -ceres_common.essentials_shifted_median)
  }
  
  # -----------
  gene_effect_long_new <- getFileData(file_effect) 
  
  if ("matrix" %in% class(gene_effect_long_new)) {
    gene_effect_long_new <- gene_effect_long_new  %>% 
      as.data.frame() %>%
      tibble::rownames_to_column("depmap") 
  } else {
    gene_effect_long_new <- gene_effect_long_new %>%
      dplyr::rename(depmap = 1)
  }
  
  gene_effect_long_new <- gene_effect_long_new %>%
    #tidyr::pivot_longer(!depmap, names_to = "gene", values_to = "ceres") %>%
    tidyr::gather(key = "gene", value = "ceres", -depmap) %>%
    dplyr::inner_join(cellline, by = "depmap") %>%
    dplyr::select(-depmap) %>%
    separate_gene
  
  ensg <- get_gene_translation(geneid = unique(gene_effect_long_new$geneid))
  
  # ------------
  gene_dependency_long_new <- getFileData(file_dependency)
  
  if ("matrix" %in% class(gene_dependency_long_new)) {
    gene_dependency_long_new <- gene_dependency_long_new %>%
      as.data.frame() %>%
      tibble::rownames_to_column("depmap")
  } else {
    gene_dependency_long_new <- gene_dependency_long_new %>%
      dplyr::rename(depmap = 1)
  }
  
  gene_dependency_long_new <- gene_dependency_long_new %>%
    tidyr::pivot_longer(!depmap, names_to = "gene", values_to = "ceres_prob") %>%
    dplyr::inner_join(cellline, by = "depmap") %>%
    dplyr::select(-depmap) %>%
    separate_gene %>%
    dplyr::mutate(ceres_prob = ifelse(ceres_prob < 1e-45, 0, ceres_prob))
  
  gene_effect_long_old <-  calc_unscaled_to_old_ceres() %>%
    dplyr::inner_join(cellline, by = "depmap") %>%
    dplyr::select(-depmap, -ceres_unscaled) %>%
    separate_gene %>%
    dplyr::rename(ceres_old = ceres)
  
  gene_effect_long <- gene_effect_long_new %>%
    dplyr::inner_join(gene_effect_long_old, by = c("symbol", "geneid", "celllinename")) %>%
    dplyr::inner_join(gene_dependency_long_new, by = c("symbol", "geneid", "celllinename")) %>%
    dplyr::inner_join(ensg, by = "geneid") %>%
    dplyr::select(celllinename, ensg, ceres, ceres_old, ceres_prob) %>%
    dplyr::mutate(depletionscreen = screen_name) %>%
    dplyr::distinct(celllinename, ensg, .keep_all = TRUE)
  
  depletion_screen <- tibble::tribble(
    ~depletionscreen, ~depletionscreendescription,
    screen_name, screen_desc
  )
  
  list(cellline.depletionscreen = depletion_screen,
       cellline.processeddepletionscore = gene_effect_long)
}



