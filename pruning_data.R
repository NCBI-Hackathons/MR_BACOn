#SNPs -> Pruning algorithm

#http://corearray.sourceforge.net/tutorials/SNPRelate/#installation-of-the-package-snprelate
#source("http://bioconductor.org/biocLite.R")
#biocLite("gdsfmt")
#biocLite("SNPRelate")

library(biomaRt)

#install.packages("rsnps")
install.packages("rsnps")
library(rsnps)

#metabolite_snp
metab_mat <- read.delim(file = "/Users/ncolaian/Documents/metab_test.txt", sep = "\t", stringsAsFactors = F)

#CAD_snp
cad_snp <- read.delim(file = "/Users/ncolaian/Documents/cad_test.txt", sep = "\t", stringsAsFactors = F)

#c("SNP", "chr_name", "chrom_start", "id.exposure", "pval.exposure")
#this is code to get old files to correct names
colnames(metab_mat)[c(1,2,7,9)] <- c("chr_name", "chrom_start", "pval.exposure", "id.exposure")
colnames(cad_snp)[c(1,2,3,9,11)] <- c("SNP", "chr_name", "chrom_start", "id.exposure", "pval.exposure")

check_position_data(metab_mat) #NEEDS FIXING
intersect_metab_cad(metab_mat, cad_snp)
clump_data(intersect_metab_cad(metab_mat, cad_snp))

#LD-Prune
clumping_on_intersect_metab <- function(matrix1) {
  library(TwoSampleMR)
  output <- clump_data(matrix1, clump_kb = 10000, clump_r2 = 0.001, clump_p1 = 1, clump_p2 = 1)
  return(output)
}

#test for chr_name and chrom_start
intersect_metab_cad <- function(metab, trait) {
  #1 intersect the metab and cad
  quick_intersect <- metab[metab$SNP %in% trait$SNP,]
  quick_intersect$proxy <- NA
  quick_intersect$r.squared <- NA
  #non-intersect
  non_intersect <- metab[!(metab$SNP %in% trait$SNP),]
  #create proxy
  for (i in 1:nrow(non_intersect)) {
    out <- proxy_search(non_intersect[i,],trait)
    if ( out != 0 ) {
      print(out)
      quick_intersect <- rbind(quick_intersect, out)
    }
  }
  return(quick_intersect)
}

proxy_search <- function(snp, trait) {
  library(proxysnps)
  #get all proxy snps
  print(snp$SNP)
  proxy <- get_proxies(query = snp$SNP, window_size = 10000, pop = "EUR") #ASK GROUP (ON PHASE 3 DATA)
  #filter proxies by LD
  proxy <- proxy[proxy$R.squared>.9,]
  #check for proxy in trait
  proxy <- proxy[proxy$ID %in% trait$SNP,]
  print(proxy)
  #no proxies in trait list
  if (nrow(proxy) == 0) {
    return(0)
  }
  #1 proxie in trait list
  else if ( nrow(proxy) == 1 ) {
    snp$proxy <- proxy$ID
    snp$r.squared <- proxy$R.squared
    return(snp)
  }
  #multiple proxi in trait list
  else{
    snp$proxy <- proxy$ID[which.max(proxy$R.squared)]
    snp$r.squared <- proxy$R.squared[which.max(proxy$R.squared)]
    return(snp)
  }
}

check_position_data <- function(mat) {
  library(biomaRt)
  #uses human g37
  snp_mart = useMart(biomart="ENSEMBL_MART_SNP", host="grch37.ensembl.org",dataset="hsapiens_snp")
  snp_ids <- mat$SNP
  print(snp_ids)
  snp_attributes = c("refsnp_id", "chr_name", "chrom_start")
  #snp filter -> filters results by the name of the variant
  snp_locations = getBM(attributes=snp_attributes, filters="snp_filter", 
                        values=snp_ids, mart=snp_mart)

  #BELOW NEEDS FIXING
  mat$chrom_start <- snp_locations$chrom_start
  mat$chr_name <- snp_locations$chr_name
  return(mat)
}
