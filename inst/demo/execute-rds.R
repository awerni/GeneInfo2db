library(RMariaDB)
library(tidyverse)
library(GeneInfo2db)
library(logger)
logger::log_threshold(TRACE)
options(dbname = "cliff6", dbhost = "localhost", dbuser = "postgres")

save_data <- function(x, filename) {
  
  log_trace("---- {filename} -----")
  dir.create("db-parts", showWarnings = FALSE)
  filename <- file.path("db-parts", sprintf("%s.rds", filename))
  
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
read_rds <- function(name) readRDS(sprintf("db-parts/%s.rds", name))

getEnsembl(db_info, "human") %>% save_data("human-getEnsembl")
getEntrez(gene_info, refseq_info, "human") %>% save_data("human-getEntrez")
getEntrezGene2EnsemblGene(db_info, "human") %>% save_data("human-getEntrezGene2EnsemblGene")

########################### Write some data ##########################################################
createDatabase("recreateSchema")
createDatabase("geneAnnotation")
createDatabase("celllineDB")
createDatabase("db_glue")

human <- readRDS("db-parts/human-getEnsembl.rds")
humanEnterez <- readRDS("db-parts/human-getEntrez.rds")
humanEntrezGene2EnsemblGene <- readRDS("db-parts/human-getEntrezGene2EnsemblGene.rds")

writeDatabase(human)
writeDatabase(humanEnterez)
writeEntrezGene2EnsemblGene(humanEntrezGene2EnsemblGene)


################## Next steps ################## 

getUniprot() %>% save_data("uniprot")
readRDS("db-parts/uniprot.rds") %>% writeDatabase()

getCelllineAnnotation() %>% save_data("getCelllineAnnotation")
readRDS("db-parts/getCelllineAnnotation.rds") %>% writeDatabase()

getMicrosatelliteStability() %>% save_data("getMicrosatelliteStability")
readRDS("db-parts/getMicrosatelliteStability.rds") %>% writeDatabase()

# --------- gene expression ------
getRNAseq() %>% save_data("getRNAseq")

readRDS("db-parts/getRNAseq.rds") %>% writeDatabase()

# --------- mutations -------------
getMutations() %>% save_data("getMutations")

readRDS("db-parts/getMutations.rds") %>% writeDatabase()
invisible(replicate(10, gc()))
modifyCanonicalTranscript()


# --------- copy numbers -----------------
getCopynumber() %>% save_data("getCopynumber")
invisible(replicate(10, gc()))
readRDS("db-parts/getCopynumber.rds") %>% writeDatabase()


# --------- protein expression -----
getProteomicsRPPA() %>% save_data("getProteomicsRPPA")
readRDS("db-parts/getProteomicsRPPA.rds") %>% writeDatabase()
getProteomicsMassSpec() %>% save_data("getProteomicsMassSpec")
readRDS("db-parts/getProteomicsMassSpec.rds") %>% writeDatabase()
invisible(replicate(10, gc()))

# --------- depletion screens ------------
getAvana() %>% save_data("getAvana")
readRDS("db-parts/getAvana.rds") %>% writeDatabase()
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
