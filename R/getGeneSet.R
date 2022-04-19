getGeneSet <- function() {
  essential_genes <- getFileData("common_essentials")
  gene_df <- separate_gene(essential_genes)
  
  geneset <- tibble::tribble(
    ~genesetname, ~species,
    "essential genes", "human"
  )
  
  geneassignment <- get_gene_translation(gene_df$geneid) %>%
    select(-geneid) %>%
    mutate(genesetname = "essential genes")
  
  list(
    public.geneset = geneset,
    public.geneassignment = geneassignment   
  )
}