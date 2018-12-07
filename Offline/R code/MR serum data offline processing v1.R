### offline MR processing for serum

rm(list=ls())

library(devtools)
install_github("MRCIEU/TwoSampleMR")
library(TwoSampleMR)

setwd("C:/Users/cavin/Desktop/MR_BACOn/Offline/R code/")

source("MR serum data offline processing functions v1.R")

path <- "../../ShinyApp/data/mr_data/pre-clumped/serum/"

metab_info <- read.delim("../../ShinyApp/data/metab_info/serum_map.txt", header = T, stringsAsFactors = F)

#### get all the files and names in metab info
mfiles <- list.files("../../ShinyApp/data/mr_data/pre-clumped/serum/")
mnames <- gsub("serum_","",mfiles)
mnames <- gsub("\\.txt","",mnames)

metab_info <- subset(metab_info, metid%in%mnames)

pvalue <- 0.05

out.matrix <- c()
out.single <- c()
for(i in c(1:nrow(metab_info)))
{
  print(paste("Doing metab",i,"out of",nrow(metab_info)))
  metab <- metab_info$metabolite[i]
  mid <- metab_info$metid[i]
  f <- mfiles[grep(mid,mfiles)]
  
  expos_data <- read.delim(paste0(path,f), header = T, stringsAsFactors = F)
  outcome_read <- tryCatch(read_outcome_data(filename = "../../ShinyApp/data/mr_data/cad_p05.txt", snps = expos_data$SNP, sep = "\t"),error=function(e){return(1)})
  
  if(!is.null(dim(outcome_read)))
  {
    harmed_data <- harmonise_data(exposure_dat = expos_data, outcome_dat = outcome_read)
    ### forcing mr_keep to TRUE forces keeping in all SNPs even those which are ambiguous; 
    ###   use only if sure about strand alignment, otherwise comment out
    harmed_data$mr_keep <- TRUE 
    
    mr.result <- mr(harmed_data)
    mr.result$outcome <- "CAD"
    mr.result$exposure <- metab
    mr.result$lci <- mr.result$b - qnorm(0.975,0,1)*mr.result$se
    mr.result$uci <- mr.result$b + qnorm(0.975,0,1)*mr.result$se
    mr.result <- mr.result[,-which(names(mr.result)%in%c("id.exposure","id.outcome"))]
    
    out.matrix <- rbind(out.matrix, mr.result)
    
    mr.single <- mr_singlesnp(harmed_data)
    mr.single$outcome <- "CAD"
    mr.single$exposure <- metab
    mr.single$lci <- mr.single$b - qnorm(0.975,0,1)*mr.single$se
    mr.single$uci <- mr.single$b + qnorm(0.975,0,1)*mr.single$se
    mr.single <- mr.single[,-which(names(mr.single)%in%c("id.exposure","id.outcome","samplesize"))]
    
    out.single <- rbind(out.single, mr.single)
  }
  
}

write.table(out.matrix, file="../Offline Results/CAD serum metablites MR results.csv", col.names=TRUE, row.names=FALSE, quote=FALSE, sep=",")
write.table(out.single, file="../Offline Results/CAD serum metablites MR results single SNP.csv", col.names=TRUE, row.names=FALSE, quote=FALSE, sep=",")

