getCelllineAvana <- function() {
  # ceres <- getCellline_CRISPR_screen(
  #   screen_name = 'Avana', 
  #   screen_desc = 'Broad Institute DepMap Avana CRISPR Screen',
  #   file_essentials = "common_essentials",
  #   file_nonessentials = "nonessentials",
  #   file_effect = "Achilles_gene_effect_CERES",
  #   file_effect_unscaled = "Achilles_gene_effect_unscaled_CERES",
  #   file_dependency = "Achilles_gene_dependency_CERES"
  # )

  chronos <- getCellline_CRISPR_screen_chronos(
    screen_name = 'Avana', 
    screen_desc = 'Broad Institute DepMap Avana CRISPR Screen',
    file_effect = "CRISPRGeneEffect",
    file_dependency = "CRISPRGeneDependency"
  )

  # fullData <- full_join(
  #   ceres$cellline.processeddepletionscore,
  #   chronos$cellline.processeddepletionscore,
  #   by = c("celllinename", "ensg", "depletionscreen")
  # )

  list(
    cellline.depletionscreen = chronos$cellline.depletionscreen,
    cellline.processeddepletionscore = chronos$cellline.processeddepletionscore
  )
}
