library(dplyr)

## Find all available human projects

getTissueProcessedRNASeq <- function() {
  
  human_projects <- recount3::available_projects()
  human_projects <- human_projects %>% filter(file_source %in% c("gtex", "tcga"))
  
  # At least for now, only TCGA is supported
  human_projects <- human_projects %>% filter(file_source %in% c("tcga"))
  
  result <- lapply(
      1:nrow(human_projects),
      processProcessedRNASeqExperiment,
      human_projects = human_projects,
      id_column = "tcga.tcga_barcode"
    )
  
  RNAseqGroup <- data.frame(
    RNAseqGroupID = 1,
    RNAseqName = "TCGA",
    RdataFilePath = NA,
    processingPipeline = ""
  ) 
  
  list(
    tissue.processedRNASeq = result %>% lapply("[[", "tissue.processedRNASeq"),
    tissue.RNAseqRun = result %>% lapply("[[", "tissue.RNAseqRun"),
    tissue.RNAseqGroup = RNAseqGroup
  )
  
}


processProcessedRNASeqExperiment <- function(id, human_projects, id_column = "tcga.tcga_barcode") {
  
  # TODO: only tcga is supported!
  proj <- human_projects[id,]
  message("Processing: ", id, " ", proj$project, " ", proj$file_source)
  rse_gene <- recount3::create_rse()
  
  # Remove duplicated genes
  ensg <- substr(SummarizedExperiment::rowData(rse_gene)[,"gene_id"], 1, 15)
  rse_gene <- rse_gene[!(duplicated(ensg) | duplicated(ensg, fromLast = TRUE)), ]
  
  # Remove duplicated tissuenames
  col_ids <- SummarizedExperiment::colData(rse_gene)[[id_column]]
  unique_ids <- tibble(col_id = col_ids) %>%
    mutate(
      id = row_number(),
      sample = substr(col_ids, 16, 16),
      clean_id = substr(col_id, 1, 15)
    ) %>%
    group_by(clean_id) %>%
    filter(max(sample) == sample) %>%
    dplyr::pull(id)
  
  rse_gene <- rse_gene[,unique_ids]
  
  # Calculate counts
  SummarizedExperiment::assay(rse_gene, "counts") <- recount3::transform_counts(rse_gene)
  
  
  to_data_frame <- function(dt, name = "counts") {
    as.data.frame.table(dt, responseName = name) %>%
      rename(ENSG = Var1, RNAseqRunID = Var2) %>%
      mutate(ENSG =  substr(ENSG, 1, 15))
  }
  
  counts <- to_data_frame(SummarizedExperiment::assay(rse_gene, "counts"))
  log2tpm <- to_data_frame(recount::getTPM(rse_gene), name = "tpm") %>%
    mutate(log2tpm = log2(tpm)) %>% select(-tpm)
  
  processedRNASeq <- counts %>% mutate(log2tpm = log2tpm$log2tpm)
  
  col_data <- SummarizedExperiment::colData(rse_gene)
  
  RNAseqRun <- data.frame(
    RNAseqRunID = rownames(col_data),
    tissuename = substring(col_data[, id_column], 1, 15),
    laboratory = "recount3",
    RNAseqGroupID = 1,
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

