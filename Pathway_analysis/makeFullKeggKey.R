library(KEGGREST)

compounds <- keggList("compound")

kegg.key <- list()

for (kegg.id in names(compounds)) {
common.names <- strsplit(compounds[[kegg.id]],"; ",fixed=T)[[1]]
kegg.key[[as.character(kegg.id)]] <- common.names
}

save(kegg.key,file="data/full_kegg_key.RData")
