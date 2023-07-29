library(dplyr)

p <- "data-raw/DB_structure/"

read_file <- function(f, keep_crlf = FALSE) {
  r <- readr::read_file(paste0(p, f))
  if (!keep_crlf) r <- r %>% gsub(pattern = "(\n|\r)", replacement = "")
  return(r)
}

# ------------ gene annotation ------------------
recreateAnnotationSchema <- read_file("recreateAnnotationSchema.sql")
geneAnnotation <- read_file("geneAnnotation.sql")

# ------------ gene annotation glue ------------
db_glue_file <- c("storedprocedure.sql",
                  "view.sql",
                  "trigger.sql",
                  "index.sql", "permission.sql")

db_glue_list <- sapply(db_glue_file, function(f) read_file(f, keep_crlf = TRUE))
db_glue_anno <- paste(db_glue_list, collapse = "")

# ------------ cellline ----------------
setSearchPath_cl <- "set search_path = cellline,public;"
celllineDB <-  paste(setSearchPath_cl, read_file("celllineDB.sql"), collapse = ";") 
recreateCelllineSchema <- read_file("recreateCelllineSchema.sql")

# ------------ cell line glue ---------
db_glue_file <- c("storedprocedureCellline.sql", 
                  "viewCellline.sql",
                  "sequenceCellline.sql",
                  "indexCellline.sql")

db_glue_list <- sapply(db_glue_file, function(f) read_file(f, keep_crlf = TRUE))
db_glue_cl <- paste(db_glue_list, collapse = "")

# ------------ cell line materialized views -------
refreshView_cl <- read_file("refreshMaterializedViewsCellline.sql") 
alternative_celllinename <- read_file("alternative_celllinenames.sql")

# ------------ tissue ----------------
setSearchPath_ti <- "set search_path = tissue,public;"
tissueDB <-  paste(setSearchPath_ti, read_file("tissueDB.sql"), collapse = ";") 
recreateTissueSchema <- read_file("recreateTissueSchema.sql")
renewTissuePanels <- read_file("renewTissuePanels.sql")

# ------------ tissue glue ---------
db_glue_file <- c("viewTissue.sql",
                  "sequenceTissue.sql", 
                  "indexTissue.sql")

db_glue_list <- sapply(db_glue_file, function(f) read_file(f, keep_crlf = TRUE))
db_glue_ti <- paste(db_glue_list, collapse = "")

# ------------ tissue materialized views -------
refreshView_ti <- read_file("refreshMaterializedViewsTissue.sql")

# --------------- save all 
save(
  recreateAnnotationSchema, geneAnnotation, db_glue_anno,
  recreateCelllineSchema, celllineDB, db_glue_cl, refreshView_cl, alternative_celllinename,
  recreateTissueSchema, tissueDB, renewTissuePanels, db_glue_ti, refreshView_ti,
  file = "data/db_schema.rda"
)
