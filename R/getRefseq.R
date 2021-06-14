getRefseq <- function(refseq_info, species_name) {

  rs <- refseq_info %>%
    dplyr::filter(species == species_name) %>%
    as.list()

  a <- safeReadFile(rs$file, col_names = c("size", "file")) %>%
    dplyr::filter(grepl("rna.fna.gz", file)) %>%
    dplyr::arrange(file)

  readFasta <- function(my_file) {
    curr_file  <- paste0(gsub("([^\\/]+$)", "", rs$file), my_file)
    print(curr_file)

    safeReadFile(curr_file, col_names = c("content")) %>%
      dplyr::filter(grepl(">", content)) %>%
      tidyr::separate(content, c("refseqid", "refseqdesc"), sep = " ", extra = "merge") %>%
      dplyr::mutate(refseqid = gsub(">", "", refseqid))
  }

  refseq_name <- purrr::map_dfr(a$file, readFasta)

  # ------- refseq --------
  start_download <- FALSE
  if (file.exists("gene2refseq.gz")) {
    file_prop <- readr::read_delim(
      "ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/", delim = " ", comment = "->",
      col_names = c("perm", "s", "user", "group", "size", "m", "d", "y_t", "file"), 
      trim_ws = TRUE
    ) %>%
      dplyr::filter(file == "gene2refseq.gz")
  
    fi <- file.info("gene2refseq.gz")
    if (file_prop$size != fi$size) {
      file.remove("gene2refseq.gz")
      start_download <- TRUE
    } 
  } else {
    start_download <- TRUE
  }
  
  if (start_download) {
    download.file("ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2refseq.gz", destfile = "gene2refseq.gz", method = "auto")
  }
  
  new_file <- paste0("gene2refseq_", rs$taxid)
  sys_command <- paste0("zcat gene2refseq.gz | egrep \"^(\\#tax_id|", rs$taxid, ")\" > ", new_file)
  system(sys_command)
     
  gene2refseq <- readr::read_tsv(new_file) %>%
    dplyr::select(taxid = `#tax_id`, geneid = GeneID, refseqid = RNA_nucleotide_accession.version) %>%
    dplyr::filter(taxid == rs$taxid) %>%
    dplyr::filter(!refseqid == "-") %>%
    unique()

  file.remove(new_file)
  
  gene2refseq %>% left_join(refseq_name, by = "refseqid")
}
