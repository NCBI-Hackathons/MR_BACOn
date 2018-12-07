#### functions for offline processing

serum_metabolite <- function(metabolite) {
  path <- "data/metab_info/"
  tissue <- "serum"
  path <- paste(path, tissue, "_map.txt", sep = "")
  f <- read.delim(path, header = T, stringsAsFactors = F)
  met <- f$metid[f$metabolite == metabolite]
  return(met)
}
