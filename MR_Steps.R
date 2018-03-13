library(TwoSampleMR)
### Pick metabolite of choice

exposure_dat <- function(gwas_filename,metabolite) {
  metabolite_subset <- subset(gwas_filename, grepl(metabolite,Phenotype))
  metabolite.data <- format_data(metabolite_subset)
  # metabolite.data <- read_exposure_data(filename = metabolite_subset,
  #                    sep = ",",
  #                    snp_col = "rsid",
  #                    beta_col = "effect",
  #                    se_col = "SE",
  #                    effect_allele_col = "a1",
  #                    other_allele_col = "a2",
  #                    eaf_col = "a1_freq",
  #                    pval_col = "p-value",
  #                    units_col = "Units",
  #                    gene_col = "Gene",
  #                    samplesize_col = "n")
  # metabolite.data$exposure <- metabolite
  return(metabolite.data)
}

disease_out_dat <- function(disease_GWAS_filename,metabolite_snp_dat) {
  disease_outcome_dat <- read_outcome_data(
    snps = metabolite_snp_dat$SNP,
    filename = disease_GWAS_filename,
    sep = "\t",
    snp_col = "SNP",
    beta_col = "log_odds",
    se_col = "log_odds_se",
    effect_allele_col = "reference_allele",
    other_allele_col = "other_allele",
    eaf_col = "ref_allele_frequency",
    pval_col = "pvalue",
    units_col = NA,
    gene_col = NA,
    samplesize_col = NA
  )
  disease_outcome_dat$outcome <- "CAD"
  return(disease_outcome_dat)
}

dat <- harmonise_data(
  exposure_dat = bmi_exp_dat, 
  outcome_dat = format.overlap.bmi.cad
)

##### EXAMPLE RUN
exposure_data <- exposure_dat(metab_qtl_input,metabolite = "Glutamine")

#Prune step from Nick??? ###
outcome_data <- disease_out_dat(disease_gwas,pruned_snp_list)
dat <- harmonise_data(exposure_dat=exposure_data, outcome_dat = outcome_data)
