loadSettings <- function() {
  options("dbname" = "bioinfo.hg38")
  options("dbhost" = "charlotte")
  options("useFileDownload" = TRUE)
  options("msigdb_path" = "~/Download/")
}