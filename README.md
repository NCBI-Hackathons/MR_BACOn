<b><h1>CATMInT (Causal Association between Trait and Metabolite Inference Tool) or BACOn (Biomarker Associations for Causality with Outcomes)</h1></b>
<h1>Introduction</h1>
Causal Associations from Metabolite Data<br/>
<b>Current Goal</b>: Develop a software tool to explore mendelian randomization associations between metabolites and coronary artery disease (CAD). <br/>

<h2>What is Mendelian Randomization?</h2>
Mendelian Randomization is a means by which to test if there is evidence for a causal association between a biomarker of interest and an outcome. It is based on the random assortment of alleles that occurs during meiosis (hence the allusion to Gregor Mendel). It is sometimes referred to as "Nature's Randomized Controlled Trial" and also has roots in instrumental variable theory. The core idea is that alleles are passed down at random and may have effects on a given outcome through a specific biomarker. Since these the assignment of an allele (and it's resultant effect on a biomarker) is given to an individual by random chance - these effects are uncorrelated with sources of error and confounding that traditionally plague association tests. The instrumental variables used for Mendelian Randomization are most often single nucleotide polymorphisms (SNPs) and for BACOn our biomarkers are metabolites. The SNP-metabolite associations can be combined with SNP-CAD associations to give an estimate of the causal effect between the metabolite and CAD.<br/>

<h2>WORKFLOW</h2>
<h3>Back-end</h3>
<h4>Data acquisition and filtering</h4>
<h4>LD pruning</h4>
<h4>Mendelian Randomization</h4>

<h3>Front-end: Shiny application</h3>
<h4>User inputs:</h4>

<h4>Output</h4>
INSERT PICTURE OF SHINY FRAMEWORK

<h3>Figures</h3>
<h4>Figure 1: workflow</h4>
<h4>Figure 2: data summary</h4>
<h4>Figure 3: Shiny app interface</h4>

<h3>FUTURE GOALS</h3>
Develop a software tool to explore mendeial randomization associations between metabolites and any clinical outcomes.<br/>
<b>Future Input</b>: Users metabolite QTL data and GWAS data of interest.<br/>
<b>Future Output</b>:

<h3>References</h3>
CITE TWOSAMPLEMR PACKAGE

