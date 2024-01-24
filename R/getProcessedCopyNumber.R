#' Get Tissue Copy Number Variation Data
#'
#' @return
#' A list containing the data frame with processed copy number variation data
#' for specific genes.
#
#' @examples
#' result <- getTissueCopyNumber()
#' @export
#' 
getTissueCopyNumber <- function() {
  
  con <- getPostgresqlConnection()
  
  gene <- dplyr::tbl(con, "gene") |>
    dplyr::filter(species == "human") |>
    dplyr::collect()
  
  tissue <- dplyr::tbl(con, dbplyr::in_schema("tissue", "tissue")) |>
    dplyr::filter(vendorname == "TCGA") |>
    dplyr::select(tissuename) |>
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  projects <- TCGAbiolinks::getGDCprojects() |>
    filter(grepl("TCGA", id)) |>
    pull(project_id)
  
  result <- purrr::map_dfr(projects, getTissueProjectCopyNumber)
  result <- result |>
    dplyr::filter(ensg %in% gene$ensg) |>
    dplyr::filter(tissuename %in% tissue$tissuename)
  
  processedcopynumber <- list(
    tissue.processedcopynumber = result
  ) 
  
}

#' Get Tissue Project Copy Number Data
#'
#' Function to load copy number data from GDC
#' 
#' @param project A string. Name of the GDC project, e.g. "TCGA-ACC"
#' @param workflow A string. Name of GDC workflow to load data (default = "ASCAT3").
#' [Workflows Documentation](https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/CNV_Pipeline/)
#' 
#' @return A data frame containing relative and absolute copy number information 
#' for genes in the specified tissue project.
#' @export
#' 
#' @examples
#' result <- getTissueProjectCopyNumber("TCGA-ACC")
#' 
getTissueProjectCopyNumber <- function(project, workflow = "ASCAT3") {
  query <- TCGAbiolinks::GDCquery(
    project = project,
    data.category = "Copy Number Variation",
    data.type = "Copy Number Segment",
    access = "open"
  )
  TCGAbiolinks::GDCdownload(query)
  data_segment <- TCGAbiolinks::GDCprepare(query)
  data_segment <- getTumorTCGAdata(
    data_segment, 
    sampleColName = "Sample"  
  )
  
  query <- TCGAbiolinks::GDCquery(
    project = project,
    data.category = "Copy Number Variation",
    data.type = "Gene Level Copy Number",
    access = "open"
  )
  query_workflows <- query$results[[1]][["analysis_workflow_type"]] |>
    unique()
  
  # ASCAT3 is selected as the default workflow, but if it's not available 
  # the list of available workflows will be printed 
  # and one of them needs to be chosen 
  
  if (is.null(workflow) &
      length(query_workflows) == 1) {
    message("One workflow detected: ", query_workflows)
  } else if (is.null(workflow) &
             length(workflow) > 1) {
    stop(
      "Number of available workflows: ",
      length(query_workflows),
      "\nPlease use one of the following workflow to extract the data:\n",
      paste(query_workflows, collapse = "\n")
    )
  } else if (!is.null(workflow) &
             workflow %in% query_workflows) {
    message(
      "Available workflows:\n",
      paste(query_workflows, collapse = "\n"),
      "\nSelected workflow: ",
      workflow
    )
    query <- TCGAbiolinks::GDCquery(
      project = project,
      data.category = "Copy Number Variation",
      data.type = "Gene Level Copy Number",
      access = "open",
      workflow.type = workflow
    )
  } else {
    stop(
      "Not recognised `workflow` argument: ",
      workflow,
      "\nNumber of available workflows: ",
      length(query_workflows),
      "\nPlease use one of the following workflows to extract the data:\n",
      paste(query_workflows, collapse = "\n")
    )
  }
  
  TCGAbiolinks::GDCdownload(query)
  data_gene <- TCGAbiolinks::GDCprepare(query)
  
  segment_ranges <- with(
    data_segment,
    GenomicRanges::GRanges(
      seqnames = paste0("chr", Chromosome),
      Segment_Mean = Segment_Mean,
      Sample = Sample,
      ranges = IRanges::IRanges(start = Start, end = End),
      strand = "*"
    )
  )
  gene_ranges <- SummarizedExperiment::rowRanges(data_gene)
  names(gene_ranges)  <- getGeneId(names(gene_ranges))
  gene_ranges <- gene_ranges[!duplicated(names(gene_ranges)),]
  gene_ranges$gene_id <- names(gene_ranges)
  
  all_chromosomes <- levels(GenomicRanges::seqnames(segment_ranges))
  
  pbar <- progress::progress_bar$new(total = length(all_chromosomes))
  
  relative_copy_number <- purrr::map_dfr(
    all_chromosomes,
    function(chromosome) {
      
      segments <- segment_ranges[GenomicRanges::seqnames(segment_ranges) == chromosome,]
      genes <- gene_ranges[GenomicRanges::seqnames(gene_ranges) == chromosome,]
      overlaps <- IRanges::findOverlaps(
        query = GenomicRanges::ranges(genes), 
        subject = GenomicRanges::ranges(segments)
      )
      
      # overlap with - required for weighted average if gene
      # is overlapping more segments
      width <- IRanges::width(
        x = IRanges::overlapsRanges(
          query = GenomicRanges::ranges(genes), 
          subject = GenomicRanges::ranges(segments), 
          hits = overlaps
        )
      )
      
      genes_hits <- S4Vectors::queryHits(overlaps)
      segments_hits <- S4Vectors::subjectHits(overlaps)
      
      segment_dt <- segments |> 
        as.data.frame() |>
        dplyr::select(
          Sample,
          log2relativeCopyNumber = Segment_Mean,
          Segment_Start = start,
          Segment_End = end
        )
      
      chunk_dt <- segment_dt[segments_hits,]
      
      chunk_dt$ensg <- genes$gene_id[genes_hits]
      chunk_dt$overlap_width <- width
      
      chunk_dt <- chunk_dt |>
        dplyr::group_by(Sample, ensg) |>
        dplyr::summarise(
          log2relativecopynumber = weighted.mean(
            x = log2relativeCopyNumber,
            w = overlap_width
          ),
          .groups = "drop"
        )
      pbar$tick()
      chunk_dt
    }
  )
  
  relative_copy_number <- relative_copy_number |>
    dplyr::rename(tissuename = Sample) |>
    dplyr::mutate(tissuename = getTissueName(tissue_name = tissuename)) |>
    dplyr::distinct(tissuename, ensg, .keep_all = TRUE)
  
  anno_data <- SummarizedExperiment::colData(data_gene)
  data_gene <- data_gene[,substr(rownames(anno_data), 14, 14) == "0"]
  
  copy_raw <- SummarizedExperiment::assay(data_gene, "copy_number")
  rownames(copy_raw) <- getGeneId(rownames(copy_raw))
  copy_raw <- copy_raw[!duplicated(rownames(copy_raw)), ]
  
  abs_copy_number <- as.data.frame.table(
    copy_raw, 
    responseName = "totalabscopynumber"
  )|>
    dplyr::rename(
      ensg = Var1, 
      tissuename = Var2
    )|>
    dplyr::mutate(
      ensg = getGeneId(ensg),
      tissuename = getTissueName(tissuename)
    )|>
    dplyr::filter(
      !is.na(ensg) & !is.na(totalabscopynumber)
    )
  
  result <- relative_copy_number |> 
    dplyr::full_join(
      abs_copy_number, 
      by = c("tissuename", "ensg")
    )
  
  result
}

#' getTumorTCGAdata
#'
#' This function extracts the tumor data by examining
#' a specific column with sample names.
#' 
#' @param df A data frame to be filtered data_segment or data_gene
#' @param sampleColName A character string representing the column name 
#' where sample type (tumor or normal) is stored. "0" in 14th position stands for 
#' a tumor sample, "1" stands for a normal sample.
#' 
#' @return A filtered data frame containing only the samples of the specified type.
#' 
#' @export
#' 
getTumorTCGAdata <- function(df, sampleColName){
  sampleColNameSym <- rlang::sym(sampleColName)
  dplyr::filter(df, substr(!!sampleColNameSym, 14, 14) == 0)
}


#' getNormalTissueTCGAdata
#'
#' This function extracts the data from normal tissues by examining
#' a specific column with sample names.
#' 
#' @param df A data frame to be filtered data_segment or data_gene
#' @param sampleColName A character string representing the column name 
#' where sample type (tumor or normal) is stored. "0" in 14th position stands for 
#' a tumor sample, "1" stands for a normal sample.
#' 
#' @return A filtered data frame containing only the samples of the specified type.
#' 
#' @export
#' 
getNormalTissueTCGAdata <- function(df, sampleColName){
  sampleColNameSym <- rlang::sym(sampleColName)
  dplyr::filter(df, substr(!!sampleColNameSym, 14, 14) == 1)
}

#' getGeneId
#'
#' This function extracts a substring from the input data based on the specified
#' start and end positions.
#'
#' @param gene_ids The character vector or string from which the first 
#' 15 characters will be extracted (e.g. "ENSG00000223972.5")
#'
#' @return A character string containing the first 15 characters 
#' of the input string (e.g. "ENSG00000223972").
#'
#' @examples
#'  
#' gene_ids <- c("ENSG00000223972.5","ENSG00000227232.5","ENSG00000278267.1")
#' getGeneId(gene_ids)
#'
#' @export
#' 
getGeneId <- function(gene_ids){
  substr(gene_ids, 1, 15)
}

#' getTissueName
#'
#' This function extracts a substring from the input data based on the specified
#' start and end positions.
#'
#' @param getTissueName The character vector or string from which the first 
#' 15 characters will be extracted (e.g. "TCGA-OR-A5J1-01A")
#'
#' @return A character string containing the first 15 characters 
#' of the input string (e.g. "TCGA-OR-A5J1-01").
#'
#' @examples 
#' gene_ids <- c("TCGA-OR-A5J1-01A","TCGA-OV-B6J4-01A")
#' getTissueName(gene_ids)
#'
#' @export
#' 
getTissueName <- function(tissue_name){
  substr(tissue_name, 1, 15)
}

