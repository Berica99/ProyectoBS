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