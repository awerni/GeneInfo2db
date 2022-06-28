getTissueCopyNumber <- function(projects) {
  list(
    tissue.processedCopyNumber = purrr::map_dfr(projects, getTissueProjectCopyNumber)  
  )
}

getTissueProjectCopyNumber <- function(project) {
  query <- TCGAbiolinks::GDCquery(
    project = project,
    data.category = "Copy Number Variation",
    data.type = "Copy Number Segment",          
    access = "open"
  )
  TCGAbiolinks::GDCdownload(query)
  data_segment <- TCGAbiolinks::GDCprepare(query)
  data_segment <- data_segment %>% filter(substr(Sample,14,15) == "01")
  
  query <- TCGAbiolinks::GDCquery(
    project = project,
    data.category = "Copy Number Variation",
    data.type = "Gene Level Copy Number",          
    access = "open"
  )
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
  names(gene_ranges) <- substr(names(gene_ranges),1,15)
  gene_ranges <- gene_ranges[!duplicated(names(gene_ranges)),]
  gene_ranges$gene_id <- names(gene_ranges)
  
  all_chromosomes <- levels(GenomicRanges::seqnames(segment_ranges))
  
  pbar <- progress::progress_bar$new(total = length(all_chromosomes))
  
  relative_copy_number <- purrr::map_dfr(
    all_chromosomes,
    function(chromosome) {
      
      segments <- segment_ranges[GenomicRanges::seqnames(segment_ranges) == chromosome,]
      genes <- gene_ranges[GenomicRanges::seqnames(gene_ranges) == chromosome,]
      overlaps <- IRanges::findOverlaps(GenomicRanges::ranges(genes), GenomicRanges::ranges(segments))
      
      # overlap with - required for weighted average if gene 
      # is overlapping more segments
      width <- IRanges::width(IRanges::overlapsRanges(GenomicRanges::ranges(genes), GenomicRanges::ranges(segments), overlaps))
      
      genes_hits <- S4Vectors::queryHits(overlaps)
      segments_hits <- S4Vectors::subjectHits(overlaps)
      
      segment_dt <- segments %>% as.data.frame %>%
        select(
          Sample,
          log2relativeCopyNumber = Segment_Mean,
          Segment_Start = start,
          Segment_End = end
        )
      
      chunk_dt <- segment_dt[segments_hits,]
      
      chunk_dt$ENSG <- genes$gene_id[genes_hits]
      chunk_dt$overlap_width <- width
      
      chunk_dt <- chunk_dt %>%
        dplyr::group_by(Sample, ENSG) %>%
        dplyr::summarise(
          log2relativeCopyNumber = weighted.mean(log2relativeCopyNumber, overlap_width),
          .groups = "drop"
        )
      pbar$tick()
      chunk_dt
    }
  )
  
  relative_copy_number <- relative_copy_number %>%
    rename(tissuename = Sample) %>%
    mutate(tissuename = substr(tissuename, 1, 15))
  
  anno_data <- SummarizedExperiment::colData(data_gene)
  data_gene <- data_gene[,substr(rownames(anno_data), 14, 15) == "01"]
  
  copy_raw <- SummarizedExperiment::assay(data_gene, "copy_number")
  rownames(copy_raw) <- substr(rownames(copy_raw),1,15)
  copy_raw <- copy_raw[!duplicated(rownames(copy_raw)), ]
  
  abs_copy_number <- as.data.frame.table(copy_raw,
                                         responseName = "totalAbsCopyNumber") %>%
    dplyr::rename(ENSG = Var1, tissuename = Var2) %>%
    mutate(ENSG =  substr(ENSG, 1, 15),
           tissuename = substr(tissuename, 1, 15)) %>%
    filter(!is.na(ENSG))
  
  result <- dplyr::full_join(relative_copy_number, abs_copy_number, by = c("tissuename", "ENSG"))
  result
}
