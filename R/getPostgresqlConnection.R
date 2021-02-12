getPostgresqlConnection <- function (user = Sys.getenv("USER"), password = NA) {
  myDB <- getOption("dbname", default = db)
  DBhost <- getOption("dbhost")
  DBport <- getOption("dbport", default = 5432)
  DBuser <- getOption("dbuser", default = user)
  
  compare <- function(x, y) (x == y | y == "*")
  if (password == "" | is.na(password)) {
    pgpass <- strsplit(scan("~/.pgpass", what = "", quiet = TRUE), ":")
    n <- sapply(pgpass, function(x) {
      compare(DBhost, x[[1]]) & compare(myDB, x[[3]]) & compare(DBuser, x[[4]])
    })
    password <- pgpass[[which(n)[1]]][[5]]
  }
  drv <- RPostgres::dbDriver("Postgres")
  con <- try(RPostgres::dbConnect(drv, user = DBuser, password = password, dbname = myDB, host = DBhost, port = DBport))
  return(con)
}