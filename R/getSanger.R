getSanger <- function() {
  ceres <- get_CRISPR_screen(
    screen_name = 'Sanger',
    screen_desc = 'Sanger CRISPR Screen',
    file_essentials = "essential_genes@sanger-ceres",
    file_nonessentials = "nonessential_genes@sanger-ceres",
    file_effect = "gene_effect@sanger-ceres",
    file_effect_unscaled = "gene_effect_unscaled@sanger-ceres",
    file_dependency = "gene_dependency@sanger-ceres"
  )
  
  chronos <- get_CRISPR_screen_chronos(
    screen_name = 'Sanger',
    screen_desc = 'Sanger CRISPR Screen',
    file_effect = "gene_effect@sanger-chronos",
    file_dependency = "gene_dependency@sanger-chronos"
  )
  
  fullData <- full_join(
    ceres$cellline.processeddepletionscore,
    chronos$cellline.processeddepletionscore,
    by = c("celllinename", "ensg", "depletionscreen")
  )
  
  list(
    cellline.depletionscreen = ceres$cellline.depletionscreen,
    cellline.processeddepletionscore = fullData
  )
}
