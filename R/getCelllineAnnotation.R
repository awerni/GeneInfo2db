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

  cell_model_passport <- safeReadFile(
      "https://cog.sanger.ac.uk/cmp/download/model_list_latest.csv.gz",
      read_fnc = readr::read_csv
    ) %>%
    dplyr::filter(model_type == "Cell Line")

  cell_model_passport1 <- cell_model_passport %>%
    dplyr::select(CCLEName = CCLE_ID, cell_model_passport2 = model_id)

  cell_model_passport2 <- cell_model_passport %>%
    dplyr::select(cell_model_passport = model_id, tumortype = cancer_type)

  sample_info <- getFileData("Model") %>%
    dplyr::mutate(CCLEName = ifelse(is.na(CCLEName) | CCLEName == "", CellLineName, CCLEName)) %>%
    dplyr::mutate(CCLEName = dplyr::coalesce(CCLEName, StrippedCellLineName))

  if(anyNA(sample_info$CCLEName)) {
    print(sample_info[is.na(sample_info$CCLEName),])
    stop("sample_info$CCLEName should not contain NA!")
  }

  if ("Alias" %in% colnames(sample_info)) {
    sample_info <- sample_info %>% dplyr::rename(alias = Alias)
  }

  no <- table(sample_info$CCLEName)
  no <- names(no[no>1])
  sample_info <- sample_info %>% filter(!CCLEName %in% no)

  cl_anno <- sample_info %>%
    dplyr::left_join(cell_model_passport1, by = "CCLEName") %>%
    dplyr::mutate(species = "human",
                  gender = tolower(Sex),
                  organ = tolower(gsub("_", " ", na_if(OncotreeLineage, ""))),
                  tumortype = tolower(gsub("_", " ", na_if(OncotreePrimaryDisease, ""))),
                  histology_type = tolower(gsub("_", " ", na_if(OncotreeSubtype, ""))),
                  histology_subtype = tolower(gsub("_", " ", gsub("_cell", "-cell", na_if(MolecularSubtype, "")))),
                  cell_model_passport = dplyr::coalesce(cell_model_passport2, na_if(SangerModelID, "")),
                  cellosaurus = na_if(RRID, ""),
                  growth_type = gsub("[32]d: ", "", tolower(na_if(GrowthPattern, ""))),
                  metastatic_site = tolower(gsub("_", " ", ifelse(PrimaryOrMetastasis == "Metastatic", SampleCollectionSite, NA))),
                  morphology = tolower(ifelse(organ == "fibroblast", organ, NA)),
                  organ = ifelse(organ == "fibroblast", gsub("fibroblast ", "", histology_type), organ),
                  tumortype = ifelse(tumortype == "fibroblast", NA, tumortype),
                  comment = dplyr::na_if(PublicComments, ""),
                  public = TRUE) %>%
    dplyr::rename(celllinename = CCLEName,
                  age_at_surgery = Age,
                  cosmicid = COSMICID,
                  depmap = ModelID) %>%
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
    dplyr::select(celllinename = `CCLEName`, alternative_celllinename = CellLineName) %>%
    dplyr::filter(!is.na(alternative_celllinename) & alternative_celllinename != "") %>%
    dplyr::mutate(alternative_celllinename = stringr::str_split(alternative_celllinename, ", ")) %>%
    tidyr::unnest(alternative_celllinename) %>%
    dplyr::mutate(source = "depmap_alias")

  depmap2 <- sample_info %>%
    dplyr::select(celllinename = CCLEName, alternative_celllinename = StrippedCellLineName) %>%
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
    dplyr::filter(!is.na(alternative_celllinename)) %>%
    dplyr::filter(!alternative_celllinename %in% cl_dupl$alternative_celllinename)

  if(anyNA(cl_anno$celllinename)) {
    stop("celllinename in cl_anno cannot be NA!")
  }

  list(cellline.cellline = cl_anno,
       cellline.alternative_celllinename = cl_alternative2)
}
