[Go to the main README](https://github.com/NCBI-Hackathons/MR_BACOn/blob/master/README.md)

<h2>Pathway analysis workflow</h2>

Pathway analysis for MR BACOn.

### 1. Obtaining the complete Metabolite xml file from the Human Metabolome Database.

[**HMDB**](http://www.hmdb.ca/downloads )

### 2. Map metabolites with their HMDB (and KEGG) ids using the Chemical Translation Service.

Provided by the [West Coast Metabolomics Center](http://metabolomics.ucdavis.edu/Downloads).

[**CTS**](http://cts.fiehnlab.ucdavis.edu/ )

### 3. Parse xml file, get pathway information.
	 ./parse_pathways.pl
### 4. Get a list of metabolites that are in the same pathways as the user-defined metabolite-of-interest.
	 get_metabolites_from_pathway.R

### 5. Run TwoSampleMR for metabolites returned from step 4.
