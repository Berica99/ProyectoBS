# Leer argumentos de la terminal
args <- commandArgs(trailingOnly = TRUE)

# Obtener el identificador HPO
if (length(args) < 1) {
  stop("Debes introducir un identificador HPO")
}

hpo_id <- args[1]

# Directorio de trabajo: todo lo que se genere va a results/
setwd("results")

cat("Fenotipo seleccionado:", hpo_id, "\n")


# =============================================================================
# Parte 1: Descargar la Lista de Genes de la HPO
# =============================================================================
library(httr)
library(jsonlite)

url <- paste0("https://ontology.jax.org/api/network/annotation/", hpo_id)

response <- GET(url)
data <- content(response, as = "text", encoding = "UTF-8")
genes <- fromJSON(data)$genes

# Display the first few genes
print(head(genes))

# Total number of genes
print(nrow(genes))

# Comprobaciones y guardado que pide la guía
cat("HPO:", hpo_id, "| Fecha de consulta:", format(Sys.Date()), "\n")
cat("Símbolos repetidos:", sum(duplicated(genes$name)), "\n")
cat("Símbolos vacíos:", sum(is.na(genes$name) | genes$name == ""), "\n")
write.csv2(genes, file = "hpo_genes.csv", row.names = FALSE)

# =============================================================================
# Parte 2: Obtener la Red de Interacción con STRINGdb
# =============================================================================
library(STRINGdb)

# Fix the STRING version so results don't change when a new version comes out.
# Files are saved in the string_data folder so they aren't downloaded every time.
dir.create("string_data", showWarnings = FALSE)
string_db <- STRINGdb$new(version = "12.5", species = 9606,
                          score_threshold = 800, input_directory = "string_data")

# Map each gene to its STRING identifier
string_ids <- string_db$map(genes, "name", removeUnmappedRows = TRUE)

# Get the interactions between our genes
interaction_network <- string_db$get_interactions(string_ids$STRING_id)
interaction_network <- unique(interaction_network[, 1:2]) # remove duplicate interactions

# Replace STRING identifiers with gene names
interaction_network$from <- string_ids$name[match(interaction_network$from, string_ids$STRING_id)]
interaction_network$to <- string_ids$name[match(interaction_network$to, string_ids$STRING_id)]

print(head(interaction_network))

# Ojo: Perdemos Genes por el Camino
cat("HPO genes:", nrow(genes), "\n")
cat("Genes mapped to STRING:", nrow(string_ids), "\n")
cat("Genes not mapped:", setdiff(genes$name, string_ids$name), "\n")

# Extra guía: guardar el mapeo y la tabla de asociaciones
write.csv2(string_ids, file = "string_mapping.csv", row.names = FALSE)
write.csv2(interaction_network, file = "string_interactions.csv", row.names = FALSE)

# =============================================================================
# Parte 3: Pasar la Red a igraph y Calcular sus Propiedades
# =============================================================================
library(igraph)

# Conversión a igraph
g <- graph_from_data_frame(interaction_network, directed = FALSE)

# Genes mapped to STRING but with no interactions (so not in the network)
no_interactions <- setdiff(string_ids$name, V(g)$name)
cat("Genes with no interactions (not in the network):", length(no_interactions), "\n")

# Número de Nodos y Aristas
num_nodes <- gorder(g)  # Number of nodes
num_edges <- gsize(g)   # Number of edges

cat("Number of nodes:", num_nodes, "\n")
cat("Number of edges:", num_edges, "\n")

# Grado Medio
degree_values <- degree(g)

average_degree <- mean(degree_values)
cat("Average degree:", average_degree, "\n")

# Densidad de la Red
network_density <- edge_density(g)
cat("Network density:", network_density, "\n")

# Centralidad
centrality_closeness <- closeness(g)

cat("Closeness centrality (first 5 nodes):", head(centrality_closeness, 5), "\n")

print(components(g)$no)  # Number of components

print(head(sort(centrality_closeness, decreasing = TRUE)))  # Highest closeness

# Extra guía: bucles / aristas repetidas y tabla de control
cat("Bucles:", any_loop(g), "| Aristas múltiples:", any_multiple(g), "\n")
control <- data.frame(
  recuento = c("Genes HPO", "Genes mapeados en STRING", "Nodos de la red", "Aristas de la red",
               "Grado medio", "Densidad", "Componentes"),
  valor    = c(nrow(genes), nrow(string_ids), num_nodes, num_edges,
               average_degree, network_density, components(g)$no)
)
write.csv2(control, file = "tabla_control.csv", row.names = FALSE)

# =============================================================================
# Parte 4: Visualizar la Red
# =============================================================================
# Gráfico Básico
pdf("network_basic.pdf")
plot(g, vertex.size = 5, vertex.label.cex = 0.7, main = "Basic Interaction Network")
dev.off()

# Tamaño de los Nodos según un Atributo
pdf("network_degree_size.pdf")
plot(g, vertex.size = degree(g) / 2, vertex.label.cex = 0.8, main = "Node size by degree")
dev.off()

# Disposición de Fruchterman-Reingold
pdf("network_fruchterman_reingold.pdf")
set.seed(123)
layout <- layout_with_fr(g)
plot(g, layout = layout, vertex.color = "skyblue", vertex.size = 5, edge.width = 0.5,
     main = "Fruchterman-Reingold Layout")
dev.off()

# Disposición Circular
pdf("network_circular.pdf")
circular_layout <- layout_in_circle(g)
plot(g, layout = circular_layout, vertex.color = "lightgreen", vertex.size = 5,
     vertex.label.cex = 0.8, edge.width = 0.5, main = "Circular Layout")
dev.off()

# Sin Etiquetas
pdf("network_no_labels.pdf")
set.seed(123)
plot(g, vertex.color = "orange", vertex.size = 5, vertex.label = NA, edge.width = 0.5,
     main = "Network without labels")
dev.off()


# =============================================================================
# Parte 5: Clustering de la Red
# =============================================================================
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