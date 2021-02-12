getEntrez <- function(gene_info, refseq_info, species_name) {
  res <- getEntrezGene(gene_info, species_name)
  res$public.refseq <- getRefseq(refseq_info, species_name)
  
  return(res)
}