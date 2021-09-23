getSanger <- function() {
  get_CRISPR_screen(
    screen_name = 'Sanger',
    screen_desc = 'Sanger CRISPR Screen',
    file_essentials = "essential_genes@sanger",
    file_nonessentials = "nonessential_genes@sanger",
    file_effect = "gene_effect@sanger",
    file_effect_unscaled = "gene_effect_unscaled@sanger",
    file_dependency = "gene_dependency@sanger"
  )
}