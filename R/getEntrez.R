#' @export
getEntrez <- function(gene_info, refseq_info, species_name) {
  res <- getEntrezGene(gene_info, species_name)
  # The RefSeq is a legacy functionality to compare sequences.
  # Currently we are not using RefSeq in CLIFF.
  # It's nice to have but if it causes problems we simply skip it.
  # res$public.refseq <- getRefseq(refseq_info, species_name)

  return(res)
}
