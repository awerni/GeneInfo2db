#' @export
addCelllineLossOfY <- function() {
  sql1 <- paste0("SELECT celllinename, avg(totalabscopynumber) AS chrY_avg_abs_CN, ",
                 "avg(log2relativecopynumber) AS chrY_avg_rel_CN ",
                 "FROM cellline.processedcopynumber WHERE ensg IN ",
                 "(SELECT ensg FROM gene WHERE chromosome = 'Y' AND species = 'human') ",
                 "GROUP BY celllinename")
  sql2 <- paste0("SELECT celllinename, max(log2tpm) AS chrY_max_tpm, avg(log2TPM) AS chrY_avg_tpm, ",
                 "avg(counts) AS chrY_avg_counts ",
                 "FROM cellline.processedrnaseqview WHERE ensg IN ",
                 "(SELECT ensg FROM gene WHERE chromosome = 'Y' AND species = 'human') ",
                 "GROUP BY celllinename")

  con <- getPostgresqlConnection()
  cl_anno <- RPostgres::dbGetQuery(con, "SELECT * FROM cellline.cellline")
  data.cn <- RPostgres::dbGetQuery(con, sql1)
  data.expr <- RPostgres::dbGetQuery(con, sql2)

  data.all <- cl_anno %>%
    dplyr::inner_join(data.cn, by = "celllinename") %>%
    dplyr::inner_join(data.expr, by = "celllinename") %>%
    dplyr::rename(sex = gender)

  ## calculate LOY: cutoff at 99th percentile of female values
  perc <- data.all %>%
    dplyr::filter(!is.na(sex) & sex == "female") %>%
    dplyr::summarise_at(vars(starts_with("chry")), quantile, probs = 0.99, na.rm = TRUE) %>%
    unlist()

  # -------- chry_avg_counts should not be taken as a filter, because this is dependent on the sequencing depth
  data.loy <- data.all %>%
    dplyr::mutate(lossofy = ifelse(sex == "female" | is.na(sex), NA,
                            ifelse(#chry_avg_abs_cn <   perc["chry_avg_abs_cn.99%"] &
                                     chry_avg_rel_cn < perc["chry_avg_rel_cn.99%"] &
                                     chry_max_tpm <    perc["chry_max_tpm.99%"] &
                                     chry_avg_tpm <    perc["chry_avg_tpm.99%"],
                                   TRUE, FALSE)))

  final_data <- data.loy %>% select(celllinename, lossofy) %>% dplyr::filter(!is.na(lossofy))


  sql <- glue::glue_sql("UPDATE cellline.cellline SET lossofy = {lossofy} WHERE celllinename = {celllinename}",
                 .con = con, .envir = final_data)


  devnull <- sapply(sql, function(s)
    RPostgres::dbExecute(con, s)
  )
  RPostgres::dbDisconnect(con)
}
