#Important functions for downstream analyis
#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE) # What you need to pass in arguements

library(getopt)
library(rsconnect)
library(TwoSampleMR)

#THIS IS HOW YOU START THE APP
library(rsconnect)
#rsconnect::setAccountInfo(name='ncolaian', token='E6B7AB46AE8AC605FE01CD798617DC8A', secret='igdRgmFGAMDyzg5uw43XaAGSeQKb67h2vmI9PDHR')
rsconnect::deployApp('/Users/ncolaian/Documents/metaboliteassoc/ShinyApp/')

# params = matrix(c(
#   "tissue", "e", 1, "character",
#   "metab", "m", 1, "character",
#   "outcome", "o", "character"
# ), byrow = TRUE, ncol = 4)
# opt = getopt(params)

##### FUNCTIONS #######
#all currently are hardcoded to run from the ShinyApp directory


#FUTURE GOAL WILL BE TO MAKE USE OF THE DATASET FEATURE
perform_mr <- function(tissue, dataset, metid) {
  path <- "data/mr_data/"
  metabo <- get_metabolite(metid, tissue) #this gets the id from metabolite name
  expos_data <- read_exposure_data(filename = paste(path,tissue,".txt", sep=""), id_col = "metID", sep = "\t")
  expos_data <- expos_data[expos_data$id.exposure == metabo]
  expos_data <- clump_data(expos_data, clump_kb = 1000, clump_r2 = 0.8, clump_p1 = 1, clump_p2 = 1)
  disease_outcome <- read_outcome_data(filename = paste(path,"cad.txt", sep=""), snps = expos_data$SNP, sep = "\t")
  harmed_data <- harmonise_data(exposure_dat = expos_data, outcome_dat = disease_outcome)
  return(harmed_data)
}

#gets the metabolite id from name and tissue
get_metabolite <- function(metabolit, tissue) {
  path <- "data/metab_info/"
  path <- paste(path, tissue, "_map.txt", sep = "")
  f <- read.delim(path, header = T, stringsAsFactors = F)
  met <- f$metid[f$metabolite == metabolit]
  return(met)
}

#This returns a vector of metabolite names
get_drop_down_metabolites <- function(tissue) {
  path <- "data/metab_info/"
  path <- paste(path, tissue, "_map.txt", sep = "")
  f <- read.delim(path, header = T, stringsAsFactors = F)
  return(f$metabolite)
}
