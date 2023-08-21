library(RMariaDB)
library(tidyverse)
library(GeneInfo2db)
library(logger)


save_data <- function(x, filename) {
  
  log_trace("---- {filename} -----")
  
  dirName <- GeneInfo2db:::useLocalFileRepo("db-parts")
  dir.create(dirName, showWarnings = FALSE)
  
  filename <- file.path(dirName, sprintf("%s.rds", filename))
  
  if(is.data.frame(x)) {
    log_trace("{filename}: {nrow(x)}")
  } else if(is.list(x)) {
    nms <- names(x)
    for(n in nms){
      log_trace("{n} Nrows: {nrow(x[[n]])}")
    }
  }
  saveRDS(x, filename)
}
read_rds <- function(name) readRDS(GeneInfo2db:::useLocalFileRepo(sprintf("db-parts/%s.rds", name)))

getEnsembl(db_info, "human") %>% save_data("human-getEnsembl")
getEntrez(gene_info, refseq_info, "human") %>% save_data("human-getEntrez")
getEntrezGene2EnsemblGene(db_info, "human") %>% save_data("human-getEntrezGene2EnsemblGene")

########################### Write some data ##########################################################
createDatabase("recreateSchema")
createDatabase("geneAnnotation")
createDatabase("celllineDB")
createDatabase("db_glue")

human <- read_rds("human-getEnsembl")
humanEnterez <- read_rds("human-getEntrez")
humanEntrezGene2EnsemblGene <- read_rds("human-getEntrezGene2EnsemblGene")

writeDatabase(human)
writeDatabase(humanEnterez)
writeEntrezGene2EnsemblGene(humanEntrezGene2EnsemblGene)


################## Next steps ################## 

getUniprot() %>% save_data("uniprot")
read_rds("uniprot") %>% writeDatabase()

getCelllineAnnotation() %>% save_data("getCelllineAnnotation")
read_rds("getCelllineAnnotation") %>% writeDatabase()

getCelllineMicrosatelliteStability() %>% save_data("getCelllineMicrosatelliteStability")
read_rds("getCelllineMicrosatelliteStability") %>% writeDatabase()

# --------- gene expression ------
getCelllineRNAseq() %>% save_data("getCelllineRNAseq")
read_rds("getCelllineRNAseq") %>% writeDatabase()

# --------- mutations -------------
getCelllineMutations() %>% save_data("getCelllineMutations")

read_rds("getCelllineMutations.rds") %>% writeDatabase()
invisible(replicate(10, gc()))
modifyCelllineCanonicalTranscript()


# --------- copy numbers -----------------
getCelllineCopynumber() %>% save_data("getCelllineCopynumber")
invisible(replicate(10, gc()))
read_rds("getCelllineCopynumber.rds") %>% writeDatabase()


# --------- protein expression -----
getCelllineProteomicsRPPA() %>% save_data("getCelllineProteomicsRPPA")
read_rds("getCelllineProteomicsRPPA") %>% writeDatabase()
getCelllineProteomicsMassSpec() %>% save_data("getCelllineProteomicsMassSpec")
read_rds("getCelllineProteomicsMassSpec") %>% writeDatabase()
invisible(replicate(10, gc()))

# --------- depletion screens ------------
getCelllineAvana() %>% save_data("getCelllineAvana")
read_rds("getCelllineAvana") %>% writeDatabase()
getCelllineSanger() %>% save_data("getCelllineSanger")

read_rds("getCelllineSanger") %>% writeDatabase()

#getCelllineDrive() 

# --------- Prism drug screen ------------
getCelllinePrism() %>% save_data("getCelllinePrism")
read_rds("getCelllinePrism") %>% writeDatabase()

# --------- metabolites ------------
getCelllineMetabolomics() %>% save_data("getCelllineMetabolomics")
read_rds("getCelllineMetabolomics") %>% writeDatabase()

# ---------- metastatic map --------
getCelllineMetMap() %>% save_data("getCelllineMetMap")
read_rds("getCelllineMetMap") %>% writeDatabase()

# ---------- MSigDB ----------------
getMSigDB("v2023.1.Hs") %>% save_data("getMSigDB")
read_rds("getMSigDB") %>% writeDatabase()


# --------- gene expression signatures --------
createCelllineSigMPAS() %>%  save_data("createCelllineSigMPAS")
read_rds("createCelllineSigMPAS") %>% writeDatabase()

createCelllineSigRAS()  %>% save_data("createCelllineSigRAS")
read_rds("createCelllineSigRAS") %>% writeDatabase()


createCelllineSigTP53()  %>% save_data("createCelllineSigTP53")
read_rds("createCelllineSigTP53") %>% writeDatabase()


createCelllineSigIFN()  %>% save_data("createCelllineSigIFN")
read_rds("createCelllineSigIFN") %>% writeDatabase()

# ------- refresh Views -----------
createDatabase("refreshView")

# ----- add more alternative celllinenames ----
createDatabase("alternative_celllinename")

# ----- versions -----------
getVersion() %>% writeDatabase()
