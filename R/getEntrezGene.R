getEntrezGene <- function(gene_info, species_name) {

  db <- gene_info %>%
    dplyr::filter(species == species_name) %>%
    as.list()

  entrez_data <- read_tsv(db$file)

  e <- entrez_data %>%
    dplyr::select(taxid = `#tax_id`, geneid = GeneID, symbol = Symbol, 
                  genename = description,
                  chromosome, localisation = map_location)

  alt_symbol <- entrez_data %>%
    dplyr::select(geneid = GeneID, symbol = Synonyms) %>%
    dplyr::filter(!grepl("^-$", symbol)) %>%
    dplyr::mutate(symbol = str_split(symbol, "\\|")) %>%
    tidyr::unnest(symbol)

  list(public.entrezgene = e,
       public.altentrezgenesymbol = alt_symbol)
}