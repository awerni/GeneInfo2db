get_gene_translation <- function(geneid) {

  geneid_unique <- unique(geneid)
  
  con <- getPostgresqlConnection()
  
  # ------ translate including same gene symbol
  # sql <- paste0("SELECT g.ensg, g2e.geneid, g.symbol as ensg_symbol, e.symbol as gene_symbol FROM gene g ",
  #               "JOIN normchromentrezgene2ensemblgene g2e on g.ensg = g2e.ensg ",
  #               "JOIN entrezgene e ON e.geneid = g2e.geneid ",
  #               "WHERE g.symbol = e.symbol AND e.symbol IS NOT NULL AND g2e.geneid in (", 
  #               paste(geneid_unique, collapse = ","), ")")

  # ----- translate only based on gene to ensembl link
  sql <- paste0("SELECT g.ensg, g2e.geneid FROM gene g ",
                "JOIN normchromentrezgene2ensemblgene g2e on g.ensg = g2e.ensg ",
                "JOIN entrezgene e ON e.geneid = g2e.geneid ",
                "WHERE g2e.geneid in (", paste(geneid_unique, collapse = ","), ")")
  
  ensg <- RPostgres::dbGetQuery(con, sql)
  RPostgres::dbDisconnect(con)
  
  ensg_summary <- ensg %>%
    group_by(geneid) %>% 
    summarize(n = n()) %>% 
    filter(n > 1) # assign all ambiguous geneid <=> ensg associations
  
  ensg %>% 
    filter(!geneid %in% ensg_summary$geneid) %>% # filter ambiguous gene annotations
    select(ensg, geneid)
}
