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