loadSettings <- function() {
  options("dbname" = "bioinfo.hg38")
  options("dbhost" = "vie-bio-postgres")
  options("useFileDownload" = TRUE)
  options("msigdb_path" = "~/Download/")
}