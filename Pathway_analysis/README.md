[Go to the main README](https://github.com/NCBI-Hackathons/MR_BACOn/blob/master/README.md)

<h2>Pathway analysis workflow</h2>

Pathway analysis for MR BACOn.

### 1. Map metabolites with their HMDB (and KEGG) ids using the [Chemical Translation Service](http://cts.fiehnlab.ucdavis.edu/ ).

Provided by the [West Coast Metabolomics Center](http://metabolomics.ucdavis.edu/Downloads).

### 2. Obtain the complete metabolite xml file from the [Human Metabolome Database](http://www.hmdb.ca/downloads ).

### 3. Parse xml file, get pathway information.
	 ./parse_pathways.pl xmlfile.xml
### 4. Get a list of metabolites that are in the same pathways as the user-defined metabolite-of-interest.
	 get_metabolites_from_pathway.R

### 5. Run TwoSampleMR for each metabolite returned from step 4.

[How to run TwoSampleMR](https://github.com/NCBI-Hackathons/MR_BACOn/blob/master/RuningMR/MR_Readme.md)

### 6. Calcualte average association score for each pathway, get top ranked pathways.
