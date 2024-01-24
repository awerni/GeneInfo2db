#' @export
getVendor <- function(vn) {
  vendor <- data.frame(
    vendorname = vn,
    vendorurl = as.character(NA)
  )
  return(list(tissue.vendor = vendor))
}