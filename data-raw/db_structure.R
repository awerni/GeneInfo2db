p <- "data-raw/DB_structure/"

recreateSchema <- readr::read_file(paste0(p, "recreateSchemas.sql"))

geneAnnotation <- readr::read_file(paste0(p, "geneAnnotation.sql"))

setSearchPath <- "set search_path = cellline,public;"
celllineDB <- paste(setSearchPath, readr::read_file(paste0(p, "celllineDB.sql")), collapse = ";")

db_glue_file <- c("storedprocedure.sql", "view.sql", "trigger.sql", 
                  "storedprocedureCellline.sql", "viewCellline.sql", 
                  "triggerCellline.sql", "sequenceCellline.sql", 
                  "indexCellline.sql", "index.sql", "permission.sql")

db_glue_list <- sapply(db_glue_file, function(f) readr::read_file(paste0(p, f)))
db_glue <- paste(db_glue_list, collapse = "")

save(recreateSchema, geneAnnotation, celllineDB, db_glue, file = "data/db_schema.rdata")
