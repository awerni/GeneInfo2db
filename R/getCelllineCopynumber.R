#' @export
getCelllineCopynumber <- function() {
  con <- getPostgresqlConnection()

  gene <- dplyr::tbl(con, "gene") |>
    dplyr::filter(species == "human") |> 
    dplyr::collect()

  cellline <- dplyr::tbl(con, dbplyr::in_schema("cellline", "cellline"))  |>
    dplyr::filter(species == "human")  |> 
    dplyr::select(celllinename, depmap) |>
    dplyr::collect()

  RPostgres::dbDisconnect(con)

  DepMap_gene_cn <- getFileData("OmicsCNGene")

  if ("matrix" %in% class(DepMap_gene_cn)) {

    gene_name <- data.frame(gene = colnames(DepMap_gene_cn)) |>
      tidyr::separate(gene, c("symbol", "geneid"), sep = " ") |>
      dplyr::mutate(geneid = as.numeric(gsub("(\\(|\\))", "", geneid)))

    DepMap_gene_cn <- data.frame(
        log2cn = c(DepMap_gene_cn),
        depmap = rownames(DepMap_gene_cn),
        symbol = c(sapply(gene_name$symbol, rep, times = nrow(DepMap_gene_cn))),
        geneid = c(sapply(gene_name$geneid, rep, times = nrow(DepMap_gene_cn)))
      ) |>
      dplyr::inner_join(cellline, by = "depmap") |>
      dplyr::select(-depmap) |>
      dplyr::mutate(cn = 2*(2^log2cn - 1)) 

    gene2ensg <- getEntrezGene2ENSG(gene_name$geneid)

    DepMap_gene_cn <- DepMap_gene_cn |>
      dplyr::inner_join(gene2ensg, by = "geneid") |>
      dplyr::mutate(log2relativecopynumber = log2(cn) - 1) |>
      dplyr::select(celllinename, ensg, log2relativecopynumber) |>
      dplyr::distinct(celllinename, ensg, .keep_all = TRUE)

  } else {

    gene_name <- data.frame(gene = colnames(DepMap_gene_cn)[-1]) |>
      tidyr::separate(gene, c("symbol", "geneid"), sep = " ") |>
      dplyr::mutate(geneid = as.numeric(gsub("(\\(|\\))", "", geneid)))

    colnames(DepMap_gene_cn) <- c("depmap", as.character(gene_name$geneid))
    gene2ensg <- getEntrezGene2ENSG(gene_name$geneid)

    DepMap_gene_cn <- DepMap_gene_cn |>
      tidyr::pivot_longer(!depmap, names_to = "geneid", values_to = "log2cn") |>
      dplyr::inner_join(cellline, by = "depmap") |>
      dplyr::mutate(geneid = as.numeric(geneid),
                    log2relativecopynumber = log2(2*(2^log2cn - 1)) - 1) |>
      dplyr::inner_join(gene2ensg, by = "geneid") |>
      dplyr::select(celllinename, ensg, log2relativecopynumber) |>
      dplyr::distinct(celllinename, ensg, .keep_all = TRUE)
  }

  av_cn <- DepMap_gene_cn |>
    dplyr::group_by(celllinename) |>
    dplyr::summarize(avg_cn = mean(2*2^log2relativecopynumber))
  print(summary(av_cn$avg_cn))

  list(
    cellline.processedcopynumber = DepMap_gene_cn
  )
}