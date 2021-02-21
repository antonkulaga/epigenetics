FROM quay.io/comp-bio-aging/bsbolt

RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge
RUN conda install -c cpfarrell bsbolt

CMD python -m BSBolt
#Align               Alignment
#Index               Index Generation
#CallMethylation     Methylation Calling
#AggregateMatrix     CGmap Matrix Aggregation
#Simulate            BSBolt Illumina Read Simulation
#Impute              kNN Imputation
#Sort                Sort BAM File
#BamIndex            Index BAM file