#!/bin/bash

export R_LIBS_USER=./R_LIBS

mkdir -p ../results/data

wget "https://stringdb-downloads.org/download/protein.links.v12.0/9606.protein.links.v12.0.txt.gz" -O ../results/data/string.txt.gz

gunzip ../results/data/string.txt.gz

awk -F ' ' '{if($3 > 900) print $1 "\t" $2 "\t" $3}' ../results/data/string.txt > ../results/data/string_network.txt

wget "https://stringdb-downloads.org/download/protein.aliases.v12.0/9606.protein.aliases.v12.0.txt.gz" -O ../results/data/aliases.txt.gz

gunzip ../results/data/aliases.txt.gz

grep 'Ensembl_HGNC_symbol' ../results/data/aliases.txt | cut -f 1,2 > ../results/data/string_dict.txt

wget "https://ontology.jax.org/api/network/annotation/HP:0000548/download/gene" -O ../results/data/hpo_query.txt

Rscript analyse_net_b.R \
  -i ../results/data/string_network.txt \
  -g ../results/data/network_b.pdf \
  -d ../results/data/string_dict.txt \
  -G ../results/data/hpo_query.txt