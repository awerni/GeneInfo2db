library(RMariaDB)
library(tidyverse)
library(GeneInfo2db)
library(logger)
logger::log_threshold(TRACE)

# Be careful! Running the code below might mess up with the selected database.
# Make sure that you've selected the proper one (preferably empty one).
#dbconfig <- getDBConfig(list(dbname = "bioinfo.hg38", dbhost = "charlotte", dbuser = "andreas"))
dbconfig <- getDBConfig(list(dbname = "bioinfo_24Q2.hg38", dbhost = "charlotte", dbuser = "andreas"))

setDBconfig(dbconfig)
# YOU'VE BEEN WARNDED!

options("msigdb_path" = "/data/shared_data/msigdb_v2023.2.Hs_files_to_download_locally/msigdb_v2023.2.Hs_GMTs")

options("GeneInfo2db.ExperimentalCurlSizeRequest" = TRUE)

# ---------- Ensembl Orthologs ---------
getEnsemblOrthologs(db_compara, "human", "mouse")

# ---------- Uniprot -------------------
getUniprot() |> writeDatabase()

# ---------- MSigDB ----------------
getMSigDB("v2023.2.Hs") |> writeDatabase()

############################ CELLLINES #########################################

# --------- cellline anno ------
getCelllineAnnotation() |> writeDatabase()
getCelllineMicrosatelliteStability() |> writeDatabase()

# --------- gene expression ------
getCelllineRNAseq() |> writeDatabase()

# --------- mutations -------------
getCelllineMutation() |> writeDatabase()
modifyCelllineCanonicalTranscript()

# --------- copy numbers -----------------
getCelllineCopynumber() |> writeDatabase()

# --------- protein expression -----
getCelllineProteomicsRPPA() |> writeDatabase()
getCelllineProteomicsMassSpec() |> writeDatabase()

# --------- depletion screens ------------
getCelllineAvana() |> writeDatabase()
getCelllineSanger() |> writeDatabase()
getCelllineDrive() |> writeDatabase()

# --------- Prism drug screen ------------
getCelllinePrism() |> writeDatabase()
getCelllineDrugComb() |> writeDatabase()

# --------- metabolites ------------
getCelllineMetabolomics() |> writeDatabase()

# ---------- metastatic map --------
getCelllineMetMap() |> writeDatabase()

# ---------- gene sets -------------
getGeneSet() |> writeDatabase()
getGeneSet_surfaceome() |> writeDatabase()
getGeneSet_TF() |> writeDatabase()
getGeneSet_mTF() |> writeDatabase()
getGeneSet_network_of_cancer_genes() |> writeDatabase()

# --------- gene expression signatures --------
createCelllineSigMPAS() |> writeDatabase()
createCelllineSigRAS() |> writeDatabase()
createCelllineSigTP53() |> writeDatabase()
createCelllineSigIFN() |> writeDatabase()
createCelllineSigHRD() |> writeDatabase()
createCelllineSigMPS50() |> writeDatabase()
getCelllineGSVA() |> writeDatabase()

# ------- refresh Views -----------
createDatabase("refreshView_cl")

addCelllineLossOfY()

# ----- versions -----------
getVersion() |> writeDatabase()

# ----- add more alternative celllinenames ----
createDatabase("alternative_celllinename")
