getTissueProcessedRNASeq <- function() {
  
  human_projects <- recount3::available_projects()
  human_projects <- human_projects %>% filter(file_source %in% c("gtex", "tcga"))
  
  result <- lapply(
      1:nrow(human_projects),
      processProcessedRNASeqExperiment,
      human_projects = human_projects
    )
  
  RNAseqGroup <- data.frame(
    RNAseqGroupID = 1:2,
    RNAseqName = c("TCGA", "GTEX"),
    RdataFilePath = NA,
    processingPipeline = ""
  ) 
  
  list(
    tissue.processedRNASeq = result %>% lapply("[[", "tissue.processedRNASeq") %>% bind_rows(),
    tissue.RNAseqRun = result %>% lapply("[[", "tissue.RNAseqRun") %>% bind_rows(),
    tissue.RNAseqGroup = RNAseqGroup
  )
  
}


processProcessedRNASeqExperiment <- function(id, human_projects) {
  
  library(S4Vectors) # without this it fails on recount3 1.4.0
  # TODO: only tcga is supported!
  proj <- human_projects[id,]
  
  if(proj$file_source == "tcga") {
    
    id_column = "tcga.tcga_barcode"
    get_tissue_id <- function(x) substr(x, 1, 15)
    get_tissue_run <- function(x) substr(x[,id_column], 16, 16)
    
  } else if(proj$file_source == "gtex") {
    
    id_column = "gtex.sampid"
    get_tissue_id <- function(x) x
    get_tissue_run <- function(x) as.numeric(gsub(rownames(x), pattern = ".*\\.", replacement = ""))
    
  } else {
    stop("Other file source is not supported")
  }
  
  
  
  message("Processing: ", id, " ", proj$project, " ", proj$file_source)
  
  rse_gene <- recount3::create_rse(proj)
  
  # Remove duplicated genes
  ensg <- substr(SummarizedExperiment::rowData(rse_gene)[,"gene_id"], 1, 15)
  rse_gene <- rse_gene[!(duplicated(ensg) | duplicated(ensg, fromLast = TRUE)), ]
  
  # Remove duplicated tissuenames
  col_data <- SummarizedExperiment::colData(rse_gene)
  col_ids <- col_data[[id_column]]
  
  run_id <- get_tissue_run(col_data)
  
  unique_ids <- tibble(col_id = col_ids) %>%
    mutate(
      id = row_number(),
      sample = run_id,
      clean_id = get_tissue_id(col_id)
    ) %>%
    group_by(clean_id) %>%
    filter(max(sample) == sample) %>%
    dplyr::pull(id)
  
  rse_gene <- rse_gene[,unique_ids]
  
  # Calculate counts
  SummarizedExperiment::assay(rse_gene, "counts") <- recount3::transform_counts(rse_gene)
  
  
  to_data_frame <- function(dt, name = "counts") {
    as.data.frame.table(dt, responseName = name) %>%
      dplyr::rename(ENSG = Var1, RNAseqRunID = Var2) %>%
      mutate(ENSG =  substr(ENSG, 1, 15))
  }
  
  counts <- to_data_frame(SummarizedExperiment::assay(rse_gene, "counts"))
  log2tpm <- to_data_frame(recount::getTPM(rse_gene), name = "tpm") %>%
    mutate(log2tpm = log2(tpm)) %>% select(-tpm)
  
  processedRNASeq <- counts %>% mutate(log2tpm = log2tpm$log2tpm)
  
  col_data <- SummarizedExperiment::colData(rse_gene)
  
  
  RNAseqGroupID <- case_when(
    proj$file_source == "tcga" ~ 1,
    proj$file_source == "gtex" ~ 2 
  )
  
  RNAseqRun <- data.frame(
    RNAseqRunID = rownames(col_data),
    tissuename = get_tissue_id(col_data[, id_column]),
    laboratory = "recount3",
    RNAseqGroupID = RNAseqGroupID,
    cellbatchID = NA,
    directory = "",
    isXenograft = FALSE,
    publish = TRUE,
    comment = "",
    canonical = TRUE,
    sourceID = col_data[, id_column]
  )
  
  list(
    tissue.processedRNASeq = processedRNASeq,
    tissue.RNAseqRun = RNAseqRun
  )
  
}

