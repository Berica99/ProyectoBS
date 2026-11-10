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