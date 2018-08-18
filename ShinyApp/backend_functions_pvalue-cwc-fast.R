#Important functions for downstream analyis
#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE) # What you need to pass in arguements

#library(getopt)
#library(rsconnect)
library(TwoSampleMR)
library(ggplot2)
library(reshape2)
source("getMetabPathway.R")

#THIS IS HOW YOU START THE APP
#library(rsconnect)
#rsconnect::setAccountInfo(name='ncolaian', token='E6B7AB46AE8AC605FE01CD798617DC8A', secret='igdRgmFGAMDyzg5uw43XaAGSeQKb67h2vmI9PDHR')
#rsconnect::deployApp('/Users/ncolaian/Documents/metaboliteassoc/ShinyApp/')

# params = matrix(c(
#   "tissue", "e", 1, "character",
#   "metab", "m", 1, "character",
#   "outcome", "o", 1,"character",
#   "pvalue","q",1,"numeric"
# ), byrow = TRUE, ncol = 4)
# opt = getopt(params)

##### FUNCTIONS #######
#all currently are hardcoded to run from the ShinyApp directory


#FUTURE GOAL WILL BE TO MAKE USE OF THE DATASET FEATURE
perform_mr <- function(tissue, pvalue, dataset, metid) {
  path <- "data/mr_data/"
  clump_path <- paste0("data/mr_data/pre-clumped/",tissue,"/")
  metabo <- get_metabolite(metid, tissue) #this gets the id from metabolite name
  path <- "data/mr_data/"
  
  print(metabo)
  
  ### first check the no results file to see if metabolite even has any results
  ### if not the end quickly
  no_results <- read.table(file=paste0(path,tissue,"_noresults.txt"), header=FALSE, sep=" ", stringsAsFactors=FALSE)
  if(metabo%in%no_results$V1){return(matrix(nrow = 0,ncol = 0))}
  
  #second check just in case a metabolite with no overlap with CAD didn't get written to no_results
  if(file.exists(paste0(clump_path,tissue,"_",metabo,".txt")))
  {
    expos_data <- read.delim(paste0(clump_path,tissue,"_",metabo,".txt"), header = T, stringsAsFactors = F)
    disease_outcome <- read_outcome_data(filename = paste0(path,"cad_p05.txt"), snps = expos_data$SNP, sep = "\t")
    disease_outcome <- disease_outcome[disease_outcome$pval.outcome < pvalue,]
    harmed_data <- harmonise_data(exposure_dat = expos_data, outcome_dat = disease_outcome)
    return(harmed_data)
  } else
  {
    return(matrix(nrow = 0,ncol = 0))
  }
  

  
  
}

perform_metab_pathway_data <- function(metab_list, tiss, dataset) {
  metab_list <- list(c("leucine", "cholesterol", "kynurenine", "acetylphosphate"),
                     c("leucine", "cholesterol", "kynurenine", "alanine"),
                     c("cholesterol", "glucose", "alanine", "acetate"))
  names(metab_list) <- c("fp_4/4", "fp_3/4", "fp_1/4")
  percents <- c()
  for ( i in metab_list) {
    print(paste("path metab:",i))
    passed <- 0
    run <- 0
    for ( j in i ) {
      print(j)
      run <- run+1
      harm <- tryCatch({perform_mr(tiss,0.05,"",j)},error=function(x){return(matrix(nrow=0,ncol=0))})
      print(harm)
      #looks at MR EGGER results
      if ( nrow(harm) !=0 ) {
        passed <- passed+1
      }
    }
    #percent finding
    p <- (passed/run)*100
    percents <- append(percents, p)
  }
  names(percents) <- names(metab_list)
  p <- create_ggplot(percents)
  return(p)
}
create_ggplot<- function(named_vec) {
  dat <- data.frame(name=names(named_vec), Percentage=named_vec)
  p <- ggplot(dat,aes(x=name, y=Percentage))+
    geom_bar(stat='identity')+
    coord_flip()+
    ggtitle("Pathway Analysis")+
    xlab("Pathway Name")+
    ylab("Percentage of Metabolites Associated With Trait")+
    theme(plot.title = element_text(hjust = 0.5))
  return(p)
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



calculate2MR_pathwayAnalysis <- function(metab.name,tissue, pvalue, dataset){
  
  # Get all pathways metabolite is in, as well as associated metabolites
  pathwayAndMetabolites <- getMetabPathway(metab.name,tissue)
  
  # Empty list to store pathways that have greater than 1 metabolite in them
  pathways_continue <- list()
  
  # Empty vector to store metabolites
  metabolites_2MR <- c()
  
  # Get pathways that have more than 1 metabolite in them
  # Also get list of metabolites
  for (pathway in names(pathwayAndMetabolites)){
    if (length(pathwayAndMetabolites[[pathway]]) > 1){
      pathways_continue[[pathway]] <- pathwayAndMetabolites[[pathway]]
      metabolites_2MR <- c(metabolites_2MR,pathwayAndMetabolites[[pathway]])
    }
  }
  
  # Get unique list of metabolites
  metabolites_2MR <- unique(metabolites_2MR)
  #print(metabolites_2MR)
  # Empty list to store metabolites that have significant association with CAD
  metab_sig = c()
  for (metab in metabolites_2MR){
    #print(metab)
    mr_metab_harm <- perform_mr(tissue,pvalue,dataset,metab)
    # If there are overlapping SNPs between metabolite and disease, then perform 2-MR calculations
    if (nrow(mr_metab_harm)>0){
      mr_metab = mr(mr_metab_harm)
      # Check that pval of Inverse variance weighted method is less than 0.05 if more than 1 row of mr_metab is returned
      # Check that pval of Wald ratio method is less than 0.05 if 1 row of mr_metab is returned
      #print(mr_metab)
      if ("Wald ratio" %in% mr_metab$method){
        if (mr_metab[mr_metab["method"]=="Wald ratio","pval"] < 0.05) {metab_sig = c(metab_sig,metab)}
      }
      else if (sum((mr_metab[,"pval"]) < 0.05) >= 3){ metab_sig = c(metab_sig,metab)} ### at least three tests show significance
    }
  }
  
  
  metab_interest_in_sig = 0
  if (tolower(metab.name) %in% tolower(metab_sig)){metab_interest_in_sig = 1}
  
  # Empty vectors to store pathway association values
  pathwaynames_fordf = c()
  totalNumberMetabolites_fordf = c()
  numMetabolitesAssociatedWithDisease_fordf = c()
  metaboliteOfInterest_fordf = c()
  metaboliteOfInterestName_fordf = c()
  for (pathway in names(pathways_continue)){
    pathwaynames_fordf = c(pathwaynames_fordf,pathway)
    totalNumberMetabolites_fordf = c(totalNumberMetabolites_fordf,length(pathways_continue[[pathway]]))
    num_met_assoc_disease = sum(pathways_continue[[pathway]] %in% metab_sig)
    numMetabolitesAssociatedWithDisease_fordf = c(numMetabolitesAssociatedWithDisease_fordf,num_met_assoc_disease)
    metaboliteOfInterest_fordf = c(metaboliteOfInterest_fordf,metab_interest_in_sig)
    metaboliteOfInterestName_fordf = c(metaboliteOfInterestName_fordf,metab.name)
  }
  
  return(data.frame(pathwayNames=pathwaynames_fordf,
                    totalMetabolites=totalNumberMetabolites_fordf,
                    numMetabolitesAssociatedWithDisease=numMetabolitesAssociatedWithDisease_fordf,
                    percentMetabolites=100*numMetabolitesAssociatedWithDisease_fordf/totalNumberMetabolites_fordf,
                    metabInterest=metaboliteOfInterest_fordf,
                    metabInterestName=metaboliteOfInterestName_fordf))
  
}

plot_metab_pathway_data <- function(data){
  #data <- calculate2MR_pathwayAnalysis(metab.name,tissue, pvalue, dataset)
  names_pathways <- c()
  for (i in 1:nrow(data)){
    #names_pathways <- c(names_pathways,paste(strsplit(as.character(data[i,"pathwayNames"]),"-")[[1]][1],"(",data[i,"totalMetabolites"],")",sep=""))
    names_pathways <- c(names_pathways,paste(strsplit(as.character(data[i,"pathwayNames"]),"-")[[1]][1],
                                             "(",data[i,"numMetabolitesAssociatedWithDisease"],"/",
                                             data[i,"totalMetabolites"],")",sep=""))
  }
  df <- data.frame(pathways=names_pathways,numMetabsNotAsso=data$totalMetabolites-data$numMetabolitesAssociatedWithDisease,numMetabsAsso=data$numMetabolitesAssociatedWithDisease)
  MetabIn = data$metabInterest[1]
  MetabName = data$metabInterestName[1]
  p <- create_ggplot_PathwayAnalysis(df,MetabName,MetabIn)
  return(p)
}

create_ggplot_PathwayAnalysis<- function(dataframe_for_stackedBarPlot,metabname,isMetabIn){
  if (isMetabIn==0){addToTitle=paste(metabname," is not likely associated with disease",sep="")}
  else {addToTitle=paste(metabname," is likely associated with disease",sep="")}
  df_melted <- melt(dataframe_for_stackedBarPlot, id.var="pathways")
  p <- ggplot(df_melted,aes(x=pathways, y = value, fill = variable))+
    geom_bar(stat='identity')+
    coord_flip()+
    ggtitle(paste("Pathway Analysis: ",addToTitle,sep=""))+
    xlab("Pathway Name")+
    #ylab("Percentage of Metabolites Associated With Trait")+
    ylab("Number of Metabolites in Pathway") +
    scale_fill_discrete(name="Metabolites",labels = c("Likely Associated With Disease", "Not Likely Associated With Disease")) +
    theme(plot.title = element_text(hjust = 0.5))
  return(p)
}

