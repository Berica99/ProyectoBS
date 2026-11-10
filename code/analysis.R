
# Proyecto Biologia de Sistemas
# Analisis de redes de interaccion
# Fenotipo: Cone/cone-rod dystrophy

# Leer argumentos de la terminal
args <- commandArgs(trailingOnly = TRUE)

# Obtener el identificador HPO
if (length(args) < 1) {
  stop("Debes introducir un identificador HPO")
}

hpo_id <- args[1]

# Directorio de trabajo
if (basename(getwd()) == "code") {
  setwd("..")
}

cat("Fenotipo seleccionado:", hpo_id, "\n")

