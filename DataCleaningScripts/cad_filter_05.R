
rm(list=ls())

setwd("C:/Users/cwardcav/Desktop/GitHub/MR_BACOn/DataCleaningScripts/data/")
vv <- read.table(file="cad.add.160614.website.txt", 
                 header=TRUE, stringsAsFactors = FALSE, sep="\t", fill=TRUE, quote="")
vv <- vv[,c("markername","beta","se_dgc","effect_allele_freq","effect_allele","noneffect_allele","p_dgc")]
names(vv) <- c("SNP","beta","se","eaf","effect_allele","other_allele","pval")

write.table(vv, file="cad_p05_R.txt",col.names=TRUE, row.names=FALSE, sep="\t", quote=FALSE)