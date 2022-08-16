#' writes a list of data frames into a Postgresql database
#'
#' @return a list with a single list element called public.msigdb

getMSigDB <- function() {

  con <- getPostgresqlConnection()

  entrez_ensg <- tbl(con, "normchromentrezgene2ensemblgene") %>%
    dplyr::inner_join(tbl(con, "gene", by = "ensg") %>% filter(species == "human"), by = "ensg") %>%
    dplyr::select(ensg, geneid, chromosome) %>%
    dplyr::collect()

  DBI::dbDisconnect(con)

  gene2ensg <- unstack(entrez_ensg, ensg ~ geneid)

  msig_df <- NULL

  for (n in 1:nrow(gmt.files)) {
    g <- gmt.files[[n, "file"]]
    print(g)
    msig <- scan(paste0(getOption("msigdb_path"), "/", g), what="", sep="\n")
    msig <- strsplit(msig, "\t")

    replaceEntrezGeneHuman <- function(geneid) {
      res <- unlist(gene2ensg[geneid])
      res[!is.na(res)]
    }

    human.msig <- sapply(msig, function(x) {
        ensg <- replaceEntrezGeneHuman(x[3:length(x)])
        ret <- c(x[1:2], unique(ensg))
        unname(ret)
      }
    )

    human.msig_df <- tibble::tibble(gene_set = sapply(human.msig, function(x) x[[1]]),
                            ensg_array = paste0('{"', paste(sapply(human.msig, function(x) paste(x[c(-1, -2)], collapse = '","'))), '"}'),
                            species = "human",
                            file = gmt.files[[n, "file"]]) %>%
      left_join(gmt.files, by = "file") %>%
      select(-file)

    r_before <- nrow(human.msig_df)
    human.msig_df <- human.msig_df %>%
      dplyr::filter(!gene_set %in% msig_df$gene_set)
    r_after <- nrow(human.msig_df)

    if (r_after != r_before) warning("removed ", r_before - r_after, " redundant gene sets", immediate. = TRUE)

    msig_df <- msig_df %>%
      bind_rows(human.msig_df)

  }
  return(list(public.msigdb = msig_df))
}
