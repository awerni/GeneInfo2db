getTissueCopyNumber <- function() {
  
  con <- getPostgresqlConnection()
  
  gene <- dplyr::tbl(con, "gene") %>%
    dplyr::filter(species == "human") %>%
    dplyr::collect()
  
  RPostgres::dbDisconnect(con)
  
  projects <- TCGAbiolinks::getGDCprojects() |>
    filter(grepl("TCGA", id)) |>
    pull(project_id)
  
  result <- purrr::map_dfr(projects, getTissueProjectCopyNumber)
  result <- result |>
    dplyr::filter(ENSG %in% gene$ensg)
  
  list(
    tissue.processedcopynumber = result
  ) 
}

#' Get Tissue Project Copy Number Data
#'
#' Function to load copy number data from GDC
#' 
#' @param project A string. Name of the GDC project, e.g. "TCGA-ACC"
#' @param workflow A string. Name of GDC workflow to load data (default = "ASCAT3")
#' 
#' @return A data frame containing relative and absolute copy number information 
#' for genes in the specified tissue project.
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
  data_segment <- data_segment |>
    dplyr::filter(base::substr(Sample, 14, 14) == "0")
  
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
  # and one of them need to be chosen 
  
  if (base::is.null(workflow) &
      base::length(query_workflows) == 1) {
    base::message("One workflow detected: ", query_workflows)
  } else if (base::is.null(workflow) &
             base::length(workflow) > 1) {
    base::stop(
      "Number of avaliable workflows: ",
      base::length(query_workflows),
      "\nPlease use one of the follwoing workflow to extract the data:\n",
      paste(query_workflows, collapse = "\n")
    )
  } else if (!base::is.null(workflow) &
             workflow %in% query_workflows) {
    base::message(
      "Avaliable workflows:\n",
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
    base::stop(
      "Not recognised `workflow` argument: ",
      workflow,
      "\nNumber of avaliable workflows: ",
      base::length(query_workflows),
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
  names(gene_ranges) <- substr(names(gene_ranges), 1, 15)
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
        GenomicRanges::ranges(genes), 
        GenomicRanges::ranges(segments)
      )
      
      # overlap with - required for weighted average if gene
      # is overlapping more segments
      width <- IRanges::width(
        IRanges::overlapsRanges(
          GenomicRanges::ranges(genes), 
          GenomicRanges::ranges(segments), 
          overlaps
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
      
      chunk_dt$ENSG <- genes$gene_id[genes_hits]
      chunk_dt$overlap_width <- width
      
      chunk_dt <- chunk_dt |>
        dplyr::group_by(Sample, ENSG) |>
        dplyr::summarise(
          log2relativeCopyNumber = weighted.mean(
            log2relativeCopyNumber,
            overlap_width
          ),
          .groups = "drop"
        )
      pbar$tick()
      chunk_dt
    }
  )
  
  relative_copy_number <- relative_copy_number |>
    dplyr::rename(tissuename = Sample) |>
    dplyr::mutate(tissuename = substr(tissuename, 1, 15))
  
  anno_data <- SummarizedExperiment::colData(data_gene)
  data_gene <- data_gene[,substr(rownames(anno_data), 14, 14) == "0"]
  
  copy_raw <- SummarizedExperiment::assay(data_gene, "copy_number")
  rownames(copy_raw) <- substr(rownames(copy_raw), 1, 15)
  copy_raw <- copy_raw[!duplicated(rownames(copy_raw)), ]
  
  abs_copy_number <- as.data.frame.table(
    copy_raw, 
    responseName = "totalAbsCopyNumber"
  )|>
    dplyr::rename(
      ENSG = Var1, 
      tissuename = Var2
    )|>
    dplyr::mutate(
      ENSG = substr(ENSG, 1, 15),
      tissuename = substr(tissuename, 1, 15)
    )|>
    dplyr::filter(
      !is.na(ENSG) & !is.na(totalAbsCopyNumber)
    )
  
  result <- relative_copy_number |> 
    dplyr::full_join(
      abs_copy_number, 
      by = c("tissuename", "ENSG")
    )
  
  result
}
