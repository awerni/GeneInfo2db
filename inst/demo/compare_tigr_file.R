library(RMariaDB)
library(tidyverse)
library(GeneInfo2db)

options("dbhost" = "charlotte")
#options("dbname" = "bioinfo_21Q1.hg38")
options("dbname" = "bioinfo_test.hg38")
options("useFileDownload" = TRUE)
options("msigdb_path" = "~/Download/msigdb_v7.2_files_to_download_locally/msigdb_v7.2_GMTs/")

# ---------- Uniprot ------------------- OK
options("useFileDownload" = TRUE)
file_uniprot <- getUniprot()
options("useFileDownload" = FALSE)
taigr_uniprot <- getUniprot()

# --------- cellline anno -------------- OK
options("useFileDownload" = TRUE)
file_cl_anno <- getCelllineAnnotation()
options("useFileDownload" = FALSE)
taigr_cl_anno <- getCelllineAnnotation()

# --------- microsatellite stability --- OK
options("useFileDownload" = TRUE)
file_msi <- getMicrosatelliteStability()
options("useFileDownload" = FALSE)
taigr_msi <- getMicrosatelliteStability()

# --------- gene expression ------------ OK
options("useFileDownload" = TRUE)
file_rnaseq <- getRNAseq()
options("useFileDownload" = FALSE)
taigr_rnaseq <- getRNAseq()

# --------- mutations ------------------ OK
options("useFileDownload" = TRUE)
file_mutations <- getMutations()
options("useFileDownload" = FALSE)
taigr_mutations <- getMutations()

# --------- copy numbers --------------- OK
options("useFileDownload" = TRUE)
file_cn <- getCopynumber()
options("useFileDownload" = FALSE)
taigr_cn <- getCopynumber()

# ----- protein RPPA expression -------- OK
options("useFileDownload" = TRUE)
file_rppa <- getProteomicsRPPA()
options("useFileDownload" = FALSE)
taigr_rppa <- getProteomicsRPPA()

# --- protein MassSpec expression ------ OK
options("useFileDownload" = TRUE)       
file_massspec <- getProteomicsMassSpec()
options("useFileDownload" = FALSE)
taigr_massspec <- getProteomicsMassSpec()

# --------- depletion screens ----------
options("useFileDownload" = TRUE) # ---- OK
file_avana <- getAvana()
options("useFileDownload" = FALSE)
taigr_avana <- getAvana()

options("useFileDownload" = TRUE)
file_sanger <- getSanger()
options("useFileDownload" = FALSE)
taigr_sanger <- getSanger()

options("useFileDownload" = TRUE)
file_drive <- getDrive()
options("useFileDownload" = FALSE)
taigr_drive <- getDrive()

# --------- Prism drug screen --------- OK
options("useFileDownload" = TRUE)
file_prism <- getPrism()
options("useFileDownload" = FALSE)
taigr_prism <- getPrism()

# --------- metabolites --------------- OK
options("useFileDownload" = TRUE)
file_metabolites <- getMetabolomics()
options("useFileDownload" = FALSE)
taigr_metabolites <- getMetabolomics()

