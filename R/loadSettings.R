loadSettings <- function() {
  options("dbname" = "bioinfo.hg38")
  options("dbhost" = "vie-bio-postgres")
  options("useFileDownload" = TRUE)
  options("msigdb_path" = "~/Downloads/")
  options("geneinfo2db_local_filecache" = "~/Downloads/geneinfo2db_local_filecache")
}