library(TwoSampleMR)
### Pick metabolite of choice
#serum_file <- "200_serum.txt"
#glutamine_path <- "glutamine.csv"
#CAD_path <- "CARDIoGRAM_GWAS_RESULTS.txt"
#CAD_studies <- "CAD_example_studies.csv"
#Get path for metab_qtl_path
#They're going to need to be split in advanced
metab_qtl_path <- ""
disease_GWAS_filename <- "" #CardiogramC4D thing?#
metabolite_data <- read_exposure_data(metab_qtl_path,
                       sep = ",",
                       snp_col = "SNP",
                       beta_col = "beta.exposure",
                       se_col = "se.exposure",
                       eaf_col = "eaf.exposure",
                       effect_allele_col = "effect_allele.exposure",
                       other_allele_col = "other_allele.exposure",
                       pval_col = "pval.exposure")

metabolite_clump_data <- clump_data(metabolite_data)

disease_outcome_dat <- read_outcome_data(
    snps = metabolite_clump_data$SNP,
    filename = disease_GWAS_filename,
    sep = ",",
    snp_col = "SNP",
    beta_col = "beta",
    se_col = "se",
    effect_allele_col = "effect_allele",
    other_allele_col = "other_allele",
    eaf_col = "eaf",
    pval_col = "pval"
  )
  disease_outcome_dat$outcome <- "CAD"
  return(disease_outcome_dat)
}

### Pick disease of choice
disease_outcome_dat <- read_outcome_data(CAD_studies,
    snps = metabolite_clump_data$SNP,
    sep = ",",
    snp_col = "SNP",
    beta_col = "beta",
    se_col = "se",
    effect_allele_col = "effect_allele",
    other_allele_col = "other_allele",
    eaf_col = "eaf",
    pval_col = "pval"
  )

dat <- harmonise_data(
  exposure_dat = metabolite_clump_data, 
  outcome_dat = disease_outcome_dat
)
