loadSettings <- function() {
  
  registerGeneInfoDownloadFunction()
  options("dbname" = "bioinfo.hg38")
  options("dbhost" = "vie-bio-postgres")
  options("msigdb_path" = "~/Download/")
}