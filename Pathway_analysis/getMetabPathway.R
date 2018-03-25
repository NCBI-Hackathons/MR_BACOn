library(KEGGREST)

getMetabPathway <- function(metab.name,tissue) {

# Get the key of kegg IDs to common names
load("data/full_kegg_key.RData")

# Get kegg ID
kegg.id <- NULL
for (id in names(kegg.key)) {
if (tolower(metab.name) %in% tolower(kegg.key[[id]])) {
kegg.id <- id
break
}
}


# Get the metabolites measured in the tissue of interest
tissue.metabs <- read.table(paste("data/metab_info/",tissue,"_map.txt",sep=""),header=T,sep="\t")

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
path.metabs.ids <- paste("cpd:",names(path.metabs),sep="")
path.metabs.names <- c()
i <- 1
for (tissue.metab.name in tissue.metabs[,1]) {
for (path.metab.id in path.metabs.ids) {
if ((tolower(tissue.metab.name) %in% tolower(kegg.key[[path.metab.id]])) 
| (tolower(paste("l-",tissue.metab.name,sep="")) %in% tolower(kegg.key[[path.metab.id]])) 
| (tolower(paste("d-",tissue.metab.name,sep="")) %in% tolower(kegg.key[[path.metab.id]]))) {
path.metabs.names[i] <- tissue.metab.name
i <- i+1
break
}
}
}
path.metabs.list[[paste(path.name,path.id)]] <- path.metabs.names

#cat(path.metabs)
#cat("\n")
}
}


return(path.metabs.list)

}
