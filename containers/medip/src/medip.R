#!/usr/bin/env Rscript

if (rstudioapi::isAvailable()) {
  if (require('rstudioapi') != TRUE) {
    install.packages('rstudioapi')
  }else{
    library(rstudioapi) # load it
  }
  wdir <- dirname(getActiveDocumentContext()$path)
}else{
  wdir <- getwd()
}
import <- file.path(wdir, "imports.R")
source(import)

MeDIP <-TRUE
CNV <- FALSE
CScalc <- FALSE

# DMR params
# 
# # This p-value threshold defines DMR boundaries
# dmrBoundPvalue <- 0.1
# # Adjacency distance (=1 when windows must be exactly adjacent). This determines how far apart
# # significant windows can be and remain in the same DMR.
# adjDist <- 1000
# 
# # The maxDMRnum variable gives a maximum number of DMRs on which to calculate CpG density and other
# # information. This will need to be increased if the p-value  of interest has more DMR than this number.
# maxDMRnum <- 10000


doc <- 'Medip executable, at least two bam files and bsgenome are needed

Usage:
  medip.R [--bsgenome=<bsgenome>] [--output_folder=<output_folder>] [--extend=<extend>] [--p_adj=<p_adj>] [--uniq=<uniq>] [--shift=<shift>] [--ws=<ws>] [--diff_method=<diff_method>] [--diffnorm=<diffnorm>] [--CScalc=<CScalc>] [--CNV=<CNV>] <bams> ...

Options:
  --bsgenome=<bsgenome> [default: /data/ensembl/103/BSgenome.Sapiens.Ensembl.103]
  --output_folder=<output_folder> [default: results]
  --uniq=<uniq> [default: 1]
  --shift=<shift> [default: 0]
  --ws=<ws> [default: 300]
  --diff_method [default: edgeR]
  --extend [default: 50]
  --CScalc=<CScalc> normalizes the data by calculating local CpG density [default: FALSE]
  --CNV=<CNV> Also compute CNV (Copy Number Variation) [default: FALSE]
  --p_adj=<p_adj>  following methods are available: holm, hochberg, hommel, bonferroni (default) , BH, BY, fdr, none [default: fdr]
  --diffnorm=<diffnorm>  defines which normalisation method is applied prior to testing for differential enrichment between conditions [default: tmm]
  -h --help     Show this screen.'

debug <- TRUE
if(debug == TRUE){
  values <- docopt(doc, version="0.1", c("/data/samples/EMBED/GSE54370/GSM1313981/PRJNA236349/SRX448176/SRR1142025/aligned/SRR1142025.sorted.bam", "/data/samples/EMBED/GSE54370/GSM1313982/PRJNA236349/SRX448177/SRR1142026/aligned/SRR1142026.sorted.bam"))
} else values <- docopt(doc, version="0.1")

bams <- values$bams
bsgenome <- values$bsgenome

#To avoid artefacts caused by PCR over amplification MEDIPS determines a maximal allowed
#number of stacked reads per genomic position by a poisson distribution of stacked reads
#genome wide and by a given p-value:
  
uniq <- as.numeric(values$uniq)

shift <- as.numeric(values$shift)
ws <- as.numeric(values$ws)
diff.method <- values$diff_method
extend <-  as.numeric(values$extend)
CScalc <- as.logical(values$CScalc)
CNV <- as.logical(values$CNV)
diffnorm <- values$diffnorm
p.adj <- values$p_adj
output_folder <- if(isAbsolutePath(values$output_folder)) values$output_folder else file.path(wdir, values$output_folder)

dir.create(output_folder)
cat(str_interp('Provided values:
           bsgenome ${bsgenome}
           bams ${bams}
           uniq ${uniq}
           shift ${shift}
           ws ${ws}
           diff_method ${diff_method}
           CScalc ${CScalc}
           '))


install.packages(bsgenome, repos=NULL, type = "source")

bamFiles <- lapply(X = bams,
                   FUN = MEDIPS.createSet,
                   BSgenome =library(basename(bsgenome), character.only = TRUE),
                   extend = extend,
                   shift = shift,
                   uniq = uniq,
                   window_size = ws,
                   chr.select = NULL)

# For CpG density dependent normalization of MeDIP-seq data, we need to generate a coupling
# set. However, for some regular diff-seq it is ok to omit it 
if (CScalc) {
  CS <- MEDIPS.couplingVector(pattern = "CG", refObj = bamFiles[[1]])
} else {
  CS <- NULL
}

mset1 <- bamFiles[1]
mset2 <- bamFiles[2]

# Perform analysis
methResults <- MEDIPS.meth(MSet1 = mset1, 
                           MSet2 = mset2,
                           p.adj = p.adj,
                           diff.method = diff.method,
                           MeDIP = MeDIP,
                           CNV = CNV,
                           CSet = CS)

MEDIPS.selectSig(results = methResults, p.value = 0.01)

save(methResults,file=file.path(getwd(), output_folder, "methResults.RData"))