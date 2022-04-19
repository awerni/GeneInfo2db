library(GeneInfo2db)

sql <- "
SELECT *, pg_size_pretty(total_bytes) AS total
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
) a WHERE table_schema in ('cellline', 'public') and row_estimate > 0 order by row_estimate desc
"

dbNew <- getPostgresqlConnection()
dbNewSummary <- dbGetQuery(dbNew, statement = sql)

oldUser <- "reader"
oldName <- "bioinfo_21Q4i.hg38"
oldPassword <- ""
oldDb <-
  getPostgresqlConnection(user = oldUser,
                          password = oldPassword,
                          name = oldName)
dbOldSummary <- dbGetQuery(oldDb, statement = sql)

dbDisconnect(dbNew)
dbDisconnect(oldDb)

result <- full_join(
  dbNewSummary %>% select(table_schema, table_name, row_estimate, total, total_bytes),
  dbOldSummary %>% select(
    table_schema,
    table_name,
    old_row_estimate = row_estimate,
    old_total = total,
    old_total_bytes = total_bytes
  )
)

result %>% mutate(row_diff = round((row_estimate - old_row_estimate) / ((
  row_estimate + old_row_estimate
) / 2), 3),
size_diff = round((total_bytes - old_total_bytes) / ((
  total_bytes + old_total_bytes
) / 2), 3)) %>%
  select(
    table_schema,
    table_name,
    total,
    old_total,
    row_estimate,
    old_row_estimate,
    row_diff,
    total_bytes,
    old_total_bytes,
    size_diff
  )

