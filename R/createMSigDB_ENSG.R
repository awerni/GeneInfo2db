# ---------------------------------------------------------------------------
# --- translation of MSgiMB from entrez gene to ENSG for mouse and human
# download the files 
# 
# h.all.v7.0.entrez.gmt
# msigdb.v7.0.entrez.gmt 
# 
# from http://software.broadinstitute.org/gsea/downloads.jsp
# and put them into msig_dir.
#
# MSigDB claims to use Ensembl, but does not publish the gene sets with ENSG 
# ---------------------------------------------------------------------------

msig_dir <- getOption("msigdb_path")
if (substr(msig_dir, nchar(msig_dir), nchar(msig_dir)) != "/") { 
  msig_dir <- paste0(msig_dir, "/") 
}
gmt.files <- dir(msig_dir, pattern = "entrez.gmt$")

con <- getPostgresqlConnection()

entrez_ensg <- tbl(con, "entrezgene2ensemblgene") %>% 
  left_join(tbl(con, "gene"), by = "ensg") %>% 
  dplyr::select(ensg, geneid, chromosome) %>% 
  filter(nchar(chromosome) <= 2) %>% 
  collect()

RPostgreSQL::dbDisconnect(con)

gene2ensg <- unstack(entrez_ensg, ensg ~ geneid)

replaceEntrezGeneHuman <- function(geneid) {
  res <- unlist(gene2ensg[geneid])
  res[!is.na(res)]
}

for (g in gmt.files) {
  msig <- scan(paste0(msig_dir, g), what="", sep="\n")
  msig <- strsplit(msig, "\t")

  human.msig <- sapply(msig, function(x) {
    ensg <- replaceEntrezGeneHuman(x[3:length(x)])
    ret <- c(x[1:2], unique(ensg))
    unname(ret)
  })
}

# newMSig <- gage::readList(paste0(human_dir, "msigdb.v7.0.ensg.gmt"))
# oldMSig <- gage::readList(paste0("~/Documents/msigdb_v6.2_ENSG86_GMTs/human/msigdb.v6.2.ensg.gmt"))
# 
# newMSig_len <- sapply(newMSig, length) %>% as.data.frame() %>% rownames_to_column("sig") %>% rename(n_new = 2)
# oldMSig_len <- sapply(oldMSig, length) %>% as.data.frame() %>% rownames_to_column("sig") %>% rename(n_old = 2)
# 
# newMSig_len %>% full_join(oldMSig_len) %>% View()
