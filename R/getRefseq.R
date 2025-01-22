#' @export
getRefseq <- function(refseq_info, species_name) {

  rs <- refseq_info |>
    dplyr::filter(species == species_name) |>
    as.list()

  a <- safeReadFile(rs$file, col_names = c("size", "file")) |>
    dplyr::filter(grepl("rna.fna.gz", file)) |>
    dplyr::arrange(file)

  readFasta <- function(my_file) {
    curr_file  <- paste0(gsub("([^\\/]+$)", "", rs$file), my_file)
    print(curr_file)

    safeReadFile(curr_file, col_names = c("content")) |>
      dplyr::filter(grepl(">", content)) |>
      tidyr::separate(content, c("refseqid", "refseqdesc"), sep = " ", extra = "merge") |>
      dplyr::mutate(refseqid = gsub(">", "", refseqid))
  }

  refseq_name <- purrr::map_dfr(a$file, readFasta)

  # ------- refseq --------
  url <- "https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2refseq.gz"
  readGene2Refseq <- function(filename, rs) {
    new_file <- paste0(filename, rs$taxid)
    sys_command <- paste0(sprintf("zcat %s | egrep \"^(\\#tax_id|", filename), rs$taxid, ")\" > ", new_file)
    status <- system(sys_command)
    
    status <- system2("gzip", args = sprintf("-t %s", filename), stderr = TRUE, stdout = TRUE)
    if(any(grepl(status, pattern = "invalid compressed"))) {
      stop(status[grepl(status, pattern = "invalid compressed")])
    }
    
    gene2refseq <- readr::read_tsv(new_file) |>
      dplyr::select(taxid = `#tax_id`, geneid = GeneID, refseqid = RNA_nucleotide_accession.version) |>
      dplyr::filter(taxid == rs$taxid) |>
      dplyr::filter(!refseqid == "-") |>
      unique()
    
    file.remove(new_file)
    gene2refseq
  }
  
  timeout <- getOption("timeout")
  options("timeout" = 36000)
  gene2refseq <- safeReadFile(url, read_fnc = readGene2Refseq, rs = rs)
  options("timeout" = timeout)  
  
  
  gene2refseq |> left_join(refseq_name, by = "refseqid")
}
