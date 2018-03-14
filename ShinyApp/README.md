
[Go to the main README](https://github.com/NCBI-Hackathons/metaboliteassoc/blob/master/README.md)

# Web interface for BACON OR CATMINT

## INPUTS
The user will need to select three inputs from drop-down menus:
  1. Metabolite of interest
  2. Tissue in which metabolite-SNP association data was collected
  3. Outcome of interest (Currently only Coronary Artery Disease)
  <img src="https://github.com/NCBI-Hackathons/metaboliteassoc/blob/master/ShinyApp/Images/Inputs_UI.png" alt="Inputs" width="600">

## OUTPUTS
The user will be able to view three plots:
  1. MR-tests plot: This plot will provide the user with confidence intervals of overall effect sizes calculated by 5 Mendelian randomisation tests for their sizes for their metabolite and outcome.
  2. Funnel plot: This plots the effect sizes of each SNPs to their inverse of their standard errors and overlays the effect size calculated by MR Egger and Inverse variance weighted.
  3. Forest plot: This plot will provide confidence intervals for individual SNPs.

Users will be able to download their plots as png images and download the data as a CSV file. 

  <img src="https://github.com/NCBI-Hackathons/metaboliteassoc/blob/master/ShinyApp/Images/OutputPlots_UI_Annotated.png" alt="Output Plots" width="600">
  
  
  
