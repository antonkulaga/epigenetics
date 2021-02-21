Methylation
===========
Methylation pipeline


Description
-----------

The pipeline is based on a WDL (Workflow Description Language) standard.
Broad Institute provides a nice [video introduction](https://www.youtube.com/watch?v=aTAQ2eA_iOc&feature=youtu.be&fbclid=IwAR0r2YeeJMEh2XFmat6OIEmbmGWXEvye3UYplvSheYFl7mJ1ijR65G0awLc) which explains WDL, Cromwell and DNA-Seq pipelines.
For users with only high-school knowledge of biology I would also recommend taking any free biology 101 or genetics 101 course ( https://www.edx.org/course/introduction-to-biology-the-secret-of-life-3 is a good example) followed by epigenetic regulation of gene expression

We do not use Broad-s GATK pipeline (because we use DeepVariant as a variant caller) but common tools are similar.
All tools are dockerized, for this reason make sure that docker is installed.
Before running the pipeline with a large genome (human or mouse) make sure you have 1-1.5 TB of free space.

Prepare data
------------

[DVC](https://dvc.org/) is used for data management: it downloads annotations and can also be used to run some useful scripts.
To download the all the data and do some preprocessing use:
```bash
dvc repro
```