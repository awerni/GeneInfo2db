#' creates parts of a Postgresql database
#'
#' @param db_part a part of the database structure stored in this package
#' @return nothing

createDatabase <- function(db_part) {
  if (db_part %in% c("recreateSchema", "geneAnnotation", "celllineDB", "db_glue", "refreshView")) {

    split_SQL <- function(my_SQL) {
      s <- stringr::str_split(my_SQL, ";", simplify = FALSE) %>% unlist()
      from_to <- stringr::str_detect(s, "\\$\\$") %>% which()
      l <- length(from_to)
      if (l == 0) return(stringr::str_split(my_SQL, ";")[[1]])
      if (l %% 2 != 0) stop("SQL parsing error")
      for (n in 1:(l / 2)) {
        ft <- seq(from_to[[1]], from_to[[2]])
        new_s <- paste(s[ft], collapse = ";")
        s <- s[-ft[-1]]
        s[[from_to[[1]]]] <- new_s
        from_to <- from_to[-1:-2]
        from_to <- from_to - (length(ft) - 1)
      }
      return(s)
    }

    con <- getPostgresqlConnection()
    
    sapply(split_SQL(get(db_part)), function(s) {
      #res <- RPostgres::dbSendQuery(con, s)
      #RPostgres::dbClearResult(res)
      if (s != "") {
        print(s)
        DBI::dbExecute(con, dplyr::sql(s))
      }
    })
    
    RPostgres::dbDisconnect(con)
  } else {
    stop("unknown database part")
  }
}
