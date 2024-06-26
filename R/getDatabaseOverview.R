#' @export
getDatabaseOverview <- function() {
  sql <- "SELECT *, pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS index
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS table
  FROM (
  SELECT *, total_bytes-index_bytes-coalesce(toast_bytes,0) AS table_bytes FROM (
      SELECT c.oid,nspname AS table_schema, relname AS table_name
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = 'r'
  ) a
  ) a WHERE table_schema in ('cellline', 'tissue', 'public') and row_estimate > 0 order by row_estimate desc;"
  
  con <- getPostgresqlConnection()
  res <- RPostgres::dbSendQuery(con, sql)
  d <- dbFetch(res)
  RPostgres::dbClearResult(res)
  RPostgres::dbDisconnect(con)
  
  return(d)
}
