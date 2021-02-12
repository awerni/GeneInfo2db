getSanger <- function() {
  get_CRISPR_screen(
    'Sanger',
    'Sanger CRISPR Screen',
    "essential_genes",
    "nonessential_genes",
    "gene_effect@sanger",
    "gene_effect_unscaled@sanger",
    "gene_dependency@sanger"
  )
}