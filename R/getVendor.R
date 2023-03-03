getVendor <- function(vn) {
  vendor <- data.frame(
    vendorname = vn,
    vendorurl = as.character(NA)
  )
  return(vendor)
}