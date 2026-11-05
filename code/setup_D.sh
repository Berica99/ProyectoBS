#!/bin/bash
export R_LIBS_USER=./R_LIBS
mkdir -p "$R_LIBS_USER"

Rscript -e 'install.packages(c("igraph", "optparse"), lib=Sys.getenv("R_LIBS_USER"), repos="https://cloud.r-project.org", dependencies=c("Depends", "Imports", "LinkingTo"))'