#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."
export R_LIBS_USER=./code/R_LIBS
mkdir -p results

Rscript code/analysis.R "$@"