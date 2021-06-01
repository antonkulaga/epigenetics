#!/usr/bin/env Rscript

if (rstudioapi::isAvailable()) {
  if (require('rstudioapi') != TRUE) {
    install.packages('rstudioapi')
  }else{
    library(rstudioapi) # load it
  }
  wdir <- dirname(getActiveDocumentContext()$path)
} else {
  source(file.path(wdir, "imports.R"))
}
source(file.path(wdir, "imports.R"))

doc <- 'Medip diff expressions

Usage:
  medip_diff.R [--output_folder=<output_folder>] <meth_results>

Options:
  --output_folder=<output_folder> [default: results]
  --meth_results=<meth_results>
  -h --help     Show this screen.'

debug <- TRUE
if(debug == TRUE){
  values <- docopt(doc, version="0.1", file.path(wdir, "results", "methResults.RData"))
} else values <- docopt(doc, version="0.1")
meth_results_path <- values$meth_results

load(meth_results_path)
library("MEDIPS")
methResults
significant <- MEDIPS.selectSig(results = methResults, p.value = 0.5)
significant
