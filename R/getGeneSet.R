getGeneSet <- function() {
  essential_genes <- getFileData("AchillesCommonEssentialControls") %>%
    dplyr::rename(gene = Gene) %>%
    dplyr::mutate(genesetname = "essential genes")

  nonessential_genes <- getFileData("AchillesNonessentialControls") %>%
    dplyr::rename(gene = Gene) %>%
    dplyr::mutate(genesetname = "non-essential genes")

  gene_df <- separate_gene(dplyr::bind_rows(essential_genes, nonessential_genes)) %>%
    dplyr::select(-symbol)

  geneset <- tibble::tribble(
    ~genesetname, ~species,
    "essential genes", "human",
    "non-essential genes", "human"
  )

  geneassignment <- get_gene_translation(gene_df$geneid) %>%
    dplyr::left_join(gene_df, by = "geneid") %>%
    dplyr::select(-geneid)

  list(
    public.geneset = geneset,
    public.geneassignment = geneassignment
  )
}
