general <- c("tidyverse", "igraph", "enrichplot")
BiocManager::install(general)

chip_seq <- c("csaw", "ChIPseeker", "clusterProfiler", "DiffBind", "edgeR", "DESeq2", "ChIPQC", "DiffBind")
BiocManager::install(chip_seq)

medips <- c("MEDIPS", "RUVSeq", "DSS")
BiocManager::install(medips)

annotations <- c("BSgenome", "BSgenome.Hsapiens.NCBI.GRCh38", "AnnotationDbi", "AHEnsDbs")
BiocManager::install(annotations)
