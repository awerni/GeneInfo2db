getEnsemblDBConnection <- function(db) {
  RMariaDB::dbConnect(MariaDB(),
                      user = "anonymous",
                      dbname = db,
                      host = "ensembldb.ensembl.org")
}