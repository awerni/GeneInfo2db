getAvana <- function() {
  get_CRISPR_screen(
    'Avana', 
    'Broad Institute DepMap Avana CRISPR Screen',
    "common_essentials",
    "nonessentials",
    "Achilles_gene_effect",
    "Achilles_gene_effect_unscaled",
    "Achilles_gene_dependency"
  )
}