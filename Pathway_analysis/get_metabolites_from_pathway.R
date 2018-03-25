setwd("path/to/Pathway_analysis")

#HMDB pathways


metaboite_of_interest <-"creatine"
#user defined

Pathmetlist <- getPathway(metaboite_of_interest)

write.csv(Pathmetlist, file = "Pathwaymetablist.csv")

#Run MR for the list of metabolites, rank pathways by association scores
#Testing using random data:
set.seed(1)
Pathmetlist$Assoc <- sample(100, size = nrow(Pathmetlist), replace = TRUE)

Ranked_paths <- aggregate(Pathmetlist[, 4], list(Pathmetlist$Pathway), mean)
colnames(Ranked_paths) <- c("Pathway", "Avg_assoc")
Ranked_paths <- Ranked_paths[order(-Ranked_paths$Avg_assoc),]

getPathway <- function(metab.name) {
  
  Pathwaylist <- read.table("Pathways_serum_metabolites.txt", sep="\t", header=TRUE)
  Pathwaylist$Pathway <- as.character(Pathwaylist$Pathway)
  Pathwaylist$HMDBID <- as.character(Pathwaylist$HMDBID)
  Pathwaylist$Metabolite <- as.character(Pathwaylist$Metabolite)
  IDlist <- read.table("SecondaryID_serum_metabolites.txt", sep="\t", header=TRUE)
  
  Metabolitelist <- read.csv("serum_metabolite_map_HMDB.csv", header = TRUE)
  
  Mergedlist <- merge(IDlist, Metabolitelist, by='SecondaryID')
  Mergedlist$Metabolite <- as.character (Mergedlist$Metabolite)
  Mergedlist$HMDBID <- as.character (Mergedlist$HMDBID)

  Query_id <- Mergedlist[Mergedlist$Metabolite == metab.name, c('HMDBID')]
  Paths<-Pathwaylist[Pathwaylist$HMDBID ==Query_id,c('Pathway')]
  Selected <-Pathwaylist[Pathwaylist$Pathway%in% Paths,]
  Remove_met <- Selected[!Selected$HMDBID == Query_id,]
  return(Remove_met)
  
}

