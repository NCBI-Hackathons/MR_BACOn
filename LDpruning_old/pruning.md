[Go to the main README](https://github.com/NCBI-Hackathons/metaboliteassoc/blob/master/README.md)

**In Progress**

To link metabolite to our trait of interest we must go through our intermediate linker of SNPs. Using the GWAS values from Metabolite QTL and Trait QTL, 

  1) Find SNPs that overlap between the metabolite and trait QTLs.
  2) The remaining non-overlaping SNPs from the metabolite QTL, find proxy SNPs in LD > .8.
  3) Intersecting all our proxy and real SNPs from the metabolite QTL with trait QTL.
  
This results in all SNPs across the genome that are shared between trait (CAD) and metabolite of interest. However, a large portion of these SNPs will be in LD with each other, meaning that when performing causal testing we will not have independent testing throughout all SNPs. To account for this, we will prune our intersecting SNPs into proxy SNPs that represent the SNPs in high LD (using the SNP that has the strongest association with the metabolite).
