loadSettings <- function() {
  
  registerGeneInfoDownloadFunction()
  options("dbname" = "bioinfo.hg38")
  options("dbhost" = "vie-bio-postgres")
  options("msigdb_path" = "~/Downloads/")
  options("geneinfo2db_local_filecache" = "~/Downloads/geneinfo2db_local_filecache")
}
