**In Progress**

Too link metabolite to our trait of interest we must go through our intermediate linker of SNPs. Using the GWAS values from Metabolite QTL and Trait QTL we first intersect the metabolite SNPs to trait SNPs performing:

  1) Finding all SNPs in LD > .8 with our metabolite associated SNPs
  2) Intersecting all our proxy and real SNPs with CAD SNPs
  
This results in a all SNPs across the genome that are shared between CAD and Metabolite. However, a large portion of these SNPs will be in LD with each other, meaning that when performing causal testing we will not have independent testing throughout all SNPs. To account for this, we will prune our intersecting SNPs into proxy SNPs that represent the SNPs in high LD ( using the SNP that has the strongest association with the metabolite)
