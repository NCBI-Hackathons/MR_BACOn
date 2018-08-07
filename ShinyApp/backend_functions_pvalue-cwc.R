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
  metabo <- get_metabolite(metid, tissue) #this gets the id from metabolite name
  
  #silly workaround to get metabolite of interest
  tmp <- read.delim(paste(path,tissue,".txt", sep=""), header = T, stringsAsFactors = F)
  tmp <- subset(tmp, metID==metabo)
  # If there are no SNPs found for the metabolite immediately terminate function and return empty matrix
  if(nrow(tmp)==0){return(matrix(nrow = 0,ncol = 0))}
  
  write.table(tmp,file=paste0(path,"expos_tmp.txt"), sep="\t",row.names=FALSE, col.names=TRUE, quote=FALSE)
  
  expos_data <- read_exposure_data(filename = paste0(path,"expos_tmp.txt"), phenotype_col = "metID", sep = "\t")
  
  #Subset data by user provided p-value
  #expos_data <- expos_data[expos_data$pval.exposure < pvalue,]
  print("Here before clumping")
  print(paste("expos_data n row:",dim(expos_data)[1]))
  #expos_data <- clump_data(expos_data, clump_kb = 1000, clump_r2 = 0.8, clump_p1 = 1, clump_p2 = 1)
  print("Here after clumping")
  print(paste("expos_data post clump n row:",dim(expos_data)[1]))
  #Read in disease GWAS 
  disease_data <- read.delim(paste(path,"cad_p05.txt", sep=""),header = T, stringsAsFactors = F)
  # If there is there is no intersection between disease SNPs and exposure SNPs, immediately terminate function and return empty matrix
  if (sum(expos_data$SNP %in% disease_data$SNP) == 0){return(matrix(nrow = 0, ncol = 0))}
  
  disease_outcome <- read_outcome_data(filename = paste(path,"cad_p05.txt", sep=""), snps = expos_data$SNP, sep = "\t")
  
  #Subset data by user provided p-value
  print(head(disease_outcome))
  disease_outcome <- disease_outcome[disease_outcome$pval.outcome < pvalue,]
  print(paste("disease_outcome n snp:",dim(disease_outcome)[1]))
  
  #Harmonize data
  harmed_data <- harmonise_data(exposure_dat = expos_data, outcome_dat = disease_outcome)
  return(harmed_data)
}

# perform_metab_pathway_data <- function(metab_list, tiss, dataset) {
#   metab_list <- list(c("leucine", "cholesterol", "kynurenine", "acetylphosphate"),
#                      c("leucine", "cholesterol", "kynurenine", "alanine"),
#                      c("cholesterol", "glucose", "alanine", "acetate"))
#   names(metab_list) <- c("fp_4/4", "fp_3/4", "fp_1/4")
#   percents <- c()
#   for ( i in metab_list) {
#     print(paste("path metab:",i))
#     passed <- 0
#     run <- 0
#     for ( j in i ) {
#       print(j)
#       run <- run+1
#       harm <- tryCatch({perform_mr(tiss,0.05,"",j)},error=function(x){return(matrix(nrow=0,ncol=0))})
#       print(harm)
#       #looks at MR EGGER results
#       if ( nrow(harm) !=0 ) {
#         passed <- passed+1
#       }
#     }
#     #percent finding
#     p <- (passed/run)*100
#     percents <- append(percents, p)
#   }
#   names(percents) <- names(metab_list)
#   p <- create_ggplot(percents)
#   return(p)
# }
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
  if (isMetabIn==0){addToTitle=paste(metabname," is not associated with disease",sep="")}
  else {addToTitle=paste(metabname," is associated with disease",sep="")}
  df_melted <- melt(dataframe_for_stackedBarPlot, id.var="pathways")
  p <- ggplot(df_melted,aes(x=pathways, y = value, fill = variable))+
    geom_bar(stat='identity')+
    coord_flip()+
    ggtitle(paste("Pathway Analysis: ",addToTitle,sep=""))+
    xlab("Pathway Name")+
    #ylab("Percentage of Metabolites Associated With Trait")+
    ylab("Number of Metabolites in Pathway") +
    scale_fill_discrete(name="Metabolites",labels = c("Not Associated With Disease", "Associated With Disease")) +
    theme(plot.title = element_text(hjust = 0.5))
  return(p)
}

# create_ggplot<- function(named_vec) {
#   dat <- data.frame(name=names(named_vec), Percentage=named_vec)
#   p <- ggplot(dat,aes(x=name, y=Percentage))+
#     geom_bar(stat='identity')+
#     coord_flip()+
#     ggtitle("Pathway Analysis")+
#     xlab("Pathway Name")+
#     #ylab("Percentage of Metabolites Associated With Trait")+
#     ylab("Number of Metabolites in Pathway") +
#     theme(plot.title = element_text(hjust = 0.5))
#   return(p)
# }

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
      else if (mr_metab[mr_metab["method"]=="Inverse variance weighted","pval"] < 0.05){ metab_sig = c(metab_sig,metab)}
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
  
  return(data.frame(pathwayNames=pathwaynames_fordf,totalMetabolites=totalNumberMetabolites_fordf,
                    numMetabolitesAssociatedWithDisease=numMetabolitesAssociatedWithDisease_fordf,
                    percentMetabolites=100*numMetabolitesAssociatedWithDisease_fordf/totalNumberMetabolites_fordf,
                    metabInterest=metaboliteOfInterest_fordf,metabInterestName=metaboliteOfInterestName_fordf))
  
}


