#' Title
#'
#' @return
#' @export
#' 
#' @importFrom dplyr na_if
#' @importFrom logger log_trace
#' @importFrom magrittr `%>%`
#'
#' @examples
getCelllineAnnotation <- function() {

  cell_model_passport <- safeReadFile("https://cog.sanger.ac.uk/cmp/download/model_list_latest.csv.gz", read_fnc = readr::read_csv) %>%
    dplyr::filter(model_type == "Cell Line")

  cell_model_passport1 <- cell_model_passport %>%
    dplyr::select(CCLE_Name = CCLE_ID, cell_model_passport2 = model_id)

  sample_info <- getFileData("sample_info") %>%
    dplyr::mutate(CCLE_Name = ifelse(is.na(CCLE_Name) | CCLE_Name == "", cell_line_name, CCLE_Name)) %>%
    dplyr::mutate(CCLE_Name = dplyr::coalesce(CCLE_Name, stripped_cell_line_name))

  if(anyNA(sample_info$CCLE_Name)) {
    print(sample_info[is.na(sample_info$CCLE_Name),])
    stop("sample_info$CCLE_Name should not contain NA!")
  }
  
  if ("Alias" %in% colnames(sample_info)) {
    sample_info = sample_info %>% rename(alias = Alias)
  }
  
  cl_anno <- sample_info %>%
    dplyr::left_join(cell_model_passport1, by = "CCLE_Name") %>%
    dplyr::mutate(species = "human",
                  gender = tolower(sex),
                  organ = gsub("_", " ", na_if(lineage, "")),
                  tumortype = tolower(gsub("_", " ", na_if(primary_disease, ""))),
                  histology_type = gsub("_", " ", na_if(lineage_subtype, "")),
                  histology_subtype = gsub("_", " ", gsub("_cell", "-cell", na_if(lineage_sub_subtype, ""))),
                  cell_model_passport = coalesce(cell_model_passport2, na_if(Sanger_Model_ID, "")),
                  cellosaurus = na_if(RRID, ""),
                  growth_type = tolower(na_if(culture_type, "")),
                  age_at_surgery = as.character(ifelse(age < 1, round(age, 2), round(age))),
                  metastatic_site = gsub("_", " ", ifelse(primary_or_metastasis == "Metastasis", sample_collection_site, NA)),
                  morphology = ifelse(organ == "fibroblast", organ, NA),
                  organ = ifelse(organ == "fibroblast", gsub("fibroblast ", "", histology_type), organ),
                  tumortype = ifelse(tumortype == "fibroblast", NA, tumortype),
                  comment = na_if(depmap_public_comments, ""),
                  public = TRUE) %>%
    dplyr::rename(celllinename = CCLE_Name,
                  cosmicid = COSMICID,
                  depmap = DepMap_ID) %>%
    dplyr::select(celllinename, species, organ, tumortype, histology_type, histology_subtype,
                  growth_type, morphology, metastatic_site, cosmicid, gender, age_at_surgery, depmap,
                  cellosaurus, cell_model_passport, comment, public)

  ccle_anno <- getFileData("Cell_lines_annotations_20181226")

  ccle1 <- ccle_anno %>%
    dplyr::select(celllinename = CCLE_ID, alternative_celllinename = Name) %>%
    dplyr::filter(!is.na(alternative_celllinename) & alternative_celllinename != "") %>%
    dplyr::mutate(source = "CCLE") %>%
    dplyr::filter(celllinename %in% cl_anno$celllinename)

  depmap1 <- sample_info %>%
    dplyr::select(celllinename = `CCLE_Name`, alternative_celllinename = alias) %>%
    dplyr::filter(!is.na(alternative_celllinename) & alternative_celllinename != "") %>%
    dplyr::mutate(alternative_celllinename = stringr::str_split(alternative_celllinename, ", ")) %>%
    tidyr::unnest(alternative_celllinename) %>%
    dplyr::mutate(source = "depmap_alias")

  depmap2 <- sample_info %>%
    dplyr::select(celllinename = CCLE_Name, alternative_celllinename = stripped_cell_line_name) %>%
    dplyr::mutate(source = "depmap_stripped_name") %>%
    dplyr::filter(celllinename %in% cl_anno$celllinename)

  sanger1 <- cell_model_passport %>%
    dplyr::select(celllinename = CCLE_ID, alternative_celllinename = model_name) %>%
    dplyr::filter(!is.na(alternative_celllinename) & alternative_celllinename != "") %>%
    dplyr::filter(!is.na(celllinename) & celllinename != "") %>%
    dplyr::mutate(source = "Sanger") %>%
    dplyr::filter(celllinename %in% cl_anno$celllinename)

  sanger2 <- cell_model_passport %>%
    dplyr::select(celllinename = CCLE_ID, alternative_celllinename = synonyms)  %>%
    dplyr::filter(!is.na(alternative_celllinename) & alternative_celllinename != "") %>%
    dplyr::mutate(alternative_celllinename = stringr::str_split(alternative_celllinename, ";")) %>%
    tidyr::unnest(alternative_celllinename) %>%
    dplyr::filter(!is.na(celllinename) & celllinename != "") %>%
    dplyr::mutate(source = "Sanger") %>%
    dplyr::filter(celllinename %in% cl_anno$celllinename)

  cl_alternative <- dplyr::bind_rows(ccle1, depmap1, depmap2, sanger1, sanger2) %>%
    dplyr::group_by(celllinename, alternative_celllinename) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(celllinename, alternative_celllinename)

  cl_dupl <- cl_alternative %>%
    dplyr::group_by(alternative_celllinename) %>%
    dplyr::summarise(n = n(), .groups = "drop") %>%
    dplyr::filter(n > 1)

  cl_alternative2 <- cl_alternative %>%
    dplyr::filter(!alternative_celllinename %in% cl_dupl$alternative_celllinename)

  if(anyNA(cl_anno$celllinename)) {
    stop("celllinename in cl_anno cannot be NA!")
  }
  
  list(cellline.cellline = cl_anno,
       cellline.alternative_celllinename = cl_alternative2)
}
