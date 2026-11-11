lib <- file.path("code", "R_LIBS")
dir.create(lib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(lib, .libPaths()))
options(repos = c(CRAN = "https://cloud.r-project.org"))

# ---- Parte 1 ----
# Install necessary packages if not already installed
if (!requireNamespace("httr", quietly = TRUE)) {
  install.packages("httr")
}
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite")
}
# ---- Parte 2 ----
# BiocManager is used to install Bioconductor packages
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
if (!requireNamespace("STRINGdb", quietly = TRUE)) {
  BiocManager::install("STRINGdb")
}

# ---- Parte 3 ----
if (!requireNamespace("igraph", quietly = TRUE)) {
  install.packages("igraph")
}


# ---- Parte 5 ----

set.seed(123)
communities <- cluster_louvain(g)

cat("Number of clusters:", length(communities), "\n")

print(sizes(communities))

pdf("network_louvain.pdf")
plot(communities, g, vertex.size = 5, vertex.label = NA, main = "Clustering with Louvain")
dev.off()

# Extra guía: tabla gen - comunidad
write.csv2(data.frame(gene = V(g)$name, community = membership(communities)),
           file = "communities.csv", row.names = FALSE)
           