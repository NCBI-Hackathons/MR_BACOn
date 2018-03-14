library(KEGGREST)

getMetabPathway <- function(metab.name) {

kegg.key <- read.table("data/key-nameToKegg_urine-metabolites.txt",header=T)

kegg.id <- as.character(kegg.key[kegg.key$Metabolite == metab.name,2])

# Define list for output pathway metabolites
path.metabs.list <- list()


# Get kegg data for the metabolite
metab.kegg <- keggGet(kegg.id)

# Extract the pathways of the metabolite
metab.paths <- metab.kegg[[1]]$PATHWAY

# Get metabolites in each pathway
for (i in 1:length(metab.paths)) {

# Get kegg pathway ID
path.general.id <- names(metab.paths)[i]

# Replace general "map" in path.id with human prefix "hsa"
path.id <- sub("map","hsa",path.general.id)

#cat(path.id)
#cat("\n")

# Get metabolites in the pathway
path.kegg <- tryCatch(keggGet(path.id)[[1]],
error=function(e) {
print(paste("KEGG pathway ",path.general.id," is not annotated for humans\n"))
return(NULL)
})

path.metabs <- path.kegg$COMPOUND
path.name <- path.kegg$NAME

if (is.null(path.metabs)) {
next
}
else {
# Match up metabolite names with the ones we are using
# to ensure no naming differences.
# Matching will be performed on kgg ID.
path.metabs.names <- as.vector(kegg.key[kegg.key$KEGG %in% names(path.metabs),1])
path.metabs.list[[paste(path.name,path.id)]] <- path.metabs.names

#cat(path.metabs)
#cat("\n")
}
}


return(path.metabs.list)

}
