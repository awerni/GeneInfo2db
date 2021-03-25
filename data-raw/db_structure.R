p <- "data-raw/DB_structure/"

recreateSchema <- readr::read_file(paste0(p, "recreateSchemas.sql")) %>%
  gsub(pattern = "(\n|\r)", replacement = "")

geneAnnotation <- readr::read_file(paste0(p, "geneAnnotation.sql")) %>%
  gsub(pattern = "(\n|\r)", replacement = "")

setSearchPath <- "set search_path = cellline,public;\r\n"
celllineDB <-  paste(setSearchPath, readr::read_file(paste0(p, "celllineDB.sql")), collapse = ";") %>%
  gsub(pattern = "(\n|\r)", replacement = "")

db_glue_file <- c("storedprocedure.sql", "storedprocedureCellline.sql", 
                  "viewCellline.sql",  "view.sql",
                  "trigger.sql", 
                  "sequenceCellline.sql", 
                  "indexCellline.sql", "index.sql", "permission.sql")

db_glue_list <- sapply(db_glue_file, function(f) readr::read_file(paste0(p, f)))
db_glue <- paste(db_glue_list, collapse = "")

refreshView <- readr::read_file(paste0(p, "refreshMaterializedViews.sql")) %>%
  gsub(pattern = "(\n|\r)", replacement = "")

alternative_celllinename <- readr::read_file(paste0(p, "alternative_celllinenames.sql")) %>%
  gsub(pattern = "(\n|\r)", replacement = "")

save(recreateSchema, geneAnnotation, celllineDB, db_glue, refreshView, alternative_celllinename, file = "data/db_schema.rdata")