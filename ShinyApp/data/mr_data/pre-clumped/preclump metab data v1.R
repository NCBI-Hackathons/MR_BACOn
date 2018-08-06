### pre-build all of the clumped data for MR analyses
rm(list=ls())

### will need to alter to be your directory for this
setwd("C:/Users/cwardcav/Desktop/GitHub/MR_BACOn/ShinyApp/data/mr_data/pre-clumped")

library(TwoSampleMR)

serum <- read.delim("../serum.txt", header = T, stringsAsFactors = F)
metabs_serum <- unique(serum$metID)

setwd("serum/")
count = 1
for(m in metabs_serum)
{
  tmp <- subset(serum, metID==m)
  write.table(tmp,file="serum_tmp.txt", sep="\t",row.names=FALSE, col.names=TRUE, quote=FALSE)
  
  expos_data <- read_exposure_data(filename ="serum_tmp.txt", phenotype_col = "metID", sep = "\t")
  expos_data <- clump_data(expos_data, clump_kb = 1000, clump_r2 = 0.8, clump_p1 = 1, clump_p2 = 1)
  write.table(expos_data, file=paste0("serum_",m,".txt"), sep="\t", col.names=TRUE, row.names=FALSE, quote=FALSE)
  print(paste("Done clumping metab",count,"out of",length(metabs_serum),"for serum"))
  count = count+1
}

### now for urine

urine <- read.delim("../../urine.txt", header = T, stringsAsFactors = F)
metabs_urine <- unique(urine$metID)

setwd("../urine/")
count = 1
for(u in metabs_urine)
{
  tmp <- subset(urine, metID==u)
  write.table(tmp,file="urine_tmp.txt", sep="\t",row.names=FALSE, col.names=TRUE, quote=FALSE)
  
  expos_data <- read_exposure_data(filename ="urine_tmp.txt", phenotype_col = "metID", sep = "\t")
  expos_data <- clump_data(expos_data, clump_kb = 1000, clump_r2 = 0.8, clump_p1 = 1, clump_p2 = 1)
  write.table(expos_data, file=paste0("urine_",m,".txt"), sep="\t", col.names=TRUE, row.names=FALSE, quote=FALSE)
  print(paste("Done clumping metab",count,"out of",length(metabs_urine),"for urine"))
  count = count+1
}
