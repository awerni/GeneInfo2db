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

getMicrosatelliteStability() %>% save_data("getMicrosatelliteStability")
read_rds("getMicrosatelliteStability") %>% writeDatabase()

# --------- gene expression ------
getRNAseq() %>% save_data("getRNAseq")
read_rds("getRNAseq") %>% writeDatabase()

# --------- mutations -------------
getMutations() %>% save_data("getMutations")

read_rds("getMutations.rds") %>% writeDatabase()
invisible(replicate(10, gc()))
modifyCanonicalTranscript()


# --------- copy numbers -----------------
getCopynumber() %>% save_data("getCopynumber")
invisible(replicate(10, gc()))
read_rds("getCopynumber.rds") %>% writeDatabase()


# --------- protein expression -----
getProteomicsRPPA() %>% save_data("getProteomicsRPPA")
read_rds("getProteomicsRPPA") %>% writeDatabase()
getProteomicsMassSpec() %>% save_data("getProteomicsMassSpec")
read_rds("getProteomicsMassSpec") %>% writeDatabase()
invisible(replicate(10, gc()))

# --------- depletion screens ------------
getAvana() %>% save_data("getAvana")
read_rds("getAvana") %>% writeDatabase()
getSanger() %>% save_data("getSanger")

read_rds("getSanger") %>% writeDatabase()

#getDrive() 

# --------- Prism drug screen ------------
getPrism() %>% save_data("getPrism")
read_rds("getPrism") %>% writeDatabase()

# --------- metabolites ------------
getMetabolomics() %>% save_data("getMetabolomics")
read_rds("getMetabolomics") %>% writeDatabase()

# ---------- metastatic map --------
getMetMap() %>% save_data("getMetMap")
read_rds("getMetMap") %>% writeDatabase()

# ---------- MSigDB ----------------
getMSigDB() %>% save_data("getMSigDB")
read_rds("getMSigDB") %>% writeDatabase()


# --------- gene expression signatures --------
createSigMPAS() %>%  save_data("createSigMPAS")
read_rds("createSigMPAS") %>% writeDatabase()

createSigRAS()  %>% save_data("createSigRAS")
read_rds("createSigRAS") %>% writeDatabase()


createSigTP53()  %>% save_data("createSigTP53")
read_rds("createSigTP53") %>% writeDatabase()


createSigIFN()  %>% save_data("createSigIFN")
read_rds("createSigIFN") %>% writeDatabase()

# ------- refresh Views -----------
createDatabase("refreshView")

# ----- add more alternative celllinenames ----
createDatabase("alternative_celllinename")

# ----- versions -----------
getVersion() %>% writeDatabase()
