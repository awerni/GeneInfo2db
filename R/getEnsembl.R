getEnsembl <- function(db_info, species_name) {
  db <- db_info %>%
    dplyr::filter(species == species_name) %>%
    as.list()

  conM <- getEnsemblDBConnection(db$database)

  gene <- getEnsemblGene(conM, db$symbol_source) %>%
    dplyr::mutate(species = species_name)

  transcript <- getEnsemblTranscript(conM, db$transcriptname_source)
  #protein <- getEnsemblProtein(conM)
  exon <- getEnsemblExon(conM)

  dbDisconnect(conM)

  list(
    public.gene = gene,
    public.transcript = transcript,
    public.exon = exon$exon,
    public.transcript2exon = exon$transcript2exon
  )
}