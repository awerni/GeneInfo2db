.onAttach <- function(libname, pkgname) {
  message <- paste(
    paste("\nWelcome to", pkgname),
    paste("  ", packageDescription(pkgname, field = "URL")),
    paste("   Version:", packageDescription(pkgname, field = "Version"), "\n\n"),
    sep = "\n"
  )
  packageStartupMessage(message)
}

.onLoad <- function(libname, pkgname) {
  loadSettings()
}
