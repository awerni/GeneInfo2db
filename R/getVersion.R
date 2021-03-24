getVersion <- function() {
  if (getOption("useFileDownload")) {
    list(public.information = file_version)
  } else {
    list(public.information = taiga_version)
  }
}