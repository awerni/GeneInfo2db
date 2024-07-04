library(RMariaDB)
library(tidyverse)
library(GeneInfo2db)
library(logger)
logger::log_threshold(TRACE)

# Be careful! Running the code below might mess up with the selected database.
# Make sure that you've selected the proper one (preferably empty one).
dbconfig <- getDBConfig(list(dbname = "bioinfo.hg38", dbhost = "localhost", dbuser = "andreas"))
setDBconfig(dbconfig)
# YOU'VE BEEN WARNDED!

options("msigdb_path" = "/data/shared_data/msigdb_v2023.2.Hs_files_to_download_locally/msigdb_v2023.2.Hs_GMTs")

options("GeneInfo2db.ExperimentalCurlSizeRequest" = TRUE)

createDatabase("recreateAnnotationSchema")
createDatabase("geneAnnotation")

createDatabase("recreateCelllineSchema")
createDatabase("recreateTissueSchema")

createDatabase("db_glue_anno")
createDatabase("celllineDB")
createDatabase("db_glue_cl")
createDatabase("tissueDB")
createDatabase("db_glue_ti")

# --------- Ensembl -------------
ensemblPath <- "data-raw/getEnsembl.Rdata"

if(file.exists(ensemblPath)) {
  ensemblEnv <- new.env()
  load(file = ensemblPath, envir = ensemblEnv)
  ensemblData <- ensemblEnv$x
  writeDatabase(ensemblData)

} else {
  # db access required
  getEnsembl(db_info, "human") |> writeDatabase()
  getEnsembl(db_info, "mouse") |> writeDatabase()
  getEnsembl(db_info, "rat") |> writeDatabase()
}


# --------- Entrez Gene and RefSeq --------
getEntrez(gene_info, refseq_info, "human") |> writeDatabase()
getEntrez(gene_info, refseq_info, "mouse") |> writeDatabase()
getEntrez(gene_info, refseq_info, "rat") |> writeDatabase()

# ---------- Entrez Gene to Ensembl Gene -----
fileEntrezGene2EnsemblGene <- "data-raw/EntrezGene2EnsemblGene.rds"

if(file.exists(fileEntrezGene2EnsemblGene)) {

  EntrezGene2EnsemblGene <- readRDS(fileEntrezGene2EnsemblGene)
  writeEntrezGene2EnsemblGene(EntrezGene2EnsemblGene$human)
  writeEntrezGene2EnsemblGene(EntrezGene2EnsemblGene$mouse)
  writeEntrezGene2EnsemblGene(EntrezGene2EnsemblGene$rat)

} else {
  getEntrezGene2EnsemblGene(db_info, "human") |> writeEntrezGene2EnsemblGene()
  getEntrezGene2EnsemblGene(db_info, "mouse") |> writeEntrezGene2EnsemblGene()
  getEntrezGene2EnsemblGene(db_info, "rat") |> writeEntrezGene2EnsemblGene()

}

# ---------- Ensembl Orthologs ---------
#getEnsemblOrthologs(db_compara, "human", "mouse")

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

# --------- gene expression signatures --------
createCelllineSigMPAS() %>% writeDatabase()
createCelllineSigRAS() %>% writeDatabase()
createCelllineSigTP53() %>% writeDatabase()
createCelllineSigIFN() %>% writeDatabase()
createCelllineSigMPS50() %>% writeDatabase()
getCelllineGSVA() %>% writeDatabase()

# ------- refresh Views -----------
createDatabase("refreshView_cl")

addCelllineLossOfY()

# ----- versions -----------
getVersion() |> writeDatabase()

# ----- add more alternative celllinenames ----
createDatabase("alternative_celllinename")

########################### TISSUES ############################################

getVendor(c("TCGA", "GTEX")) |> writeDatabase()
getTCGAAnnotation() |> writeDatabase()
createDatabase("renewTissuePanels")
getTissueMutation() |> writeDatabase()
getTCGAProteomicsRPPA() |> writeDatabase()

getTissueRNAseqGroup() |> writeDatabase()

tissue_project <- getTissueProcessedRNASeqProjects()
tissue_project_sub <- tissue_project[49:50, ]
#tissue_project_sub <- tissue_project[c(8), ]
#tissue_project_sub <- tissue_project |> filter(project == "HNSC")
d <- getTissueProcessedRNASeq(tissue_project_sub)
d2 <- filterForRNAseqImport(d)
writeDatabase(d2)


getTissueCellType() |> writeDatabase()
getTissueCopyNumber() |> writeDatabase()

if (!dir.exists("../GeneInfo2db_data/")){
  dir.create("../GeneInfo2db_data/")
} 
getTissueMetabolics("../GeneInfo2db_data/Metabolics/") |> writeDatabase()
getTissueSignalingPathway() |> writeDatabase()


getTissueGSVA() |> writeDatabase()

createTissueSigMPAS() %>% writeDatabase()
createTissueSigTP53() %>% writeDatabase()
createTissueSigIFN() %>% writeDatabase()
createTissueSigMPS50() %>% writeDatabase()

#---- missing -----
# copy number
# CMS
# weight, height, bmi
# loss of Y
# gene signatures

createDatabase("refreshView_ti")


