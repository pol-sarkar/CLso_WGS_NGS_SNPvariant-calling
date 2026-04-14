# CLso Whole Genome Sequence- Variant calling analysis (Short read-NGS)



Pipeline for analyzing **Candidatus Liberibacter solanacearum (CLso)** genomes associated with *Solanum umbelliferum* in California using reference genome CLso-ZC1.



BioProject: PRJNA1399511



---



## Overview



This repository contains scripts used to process and analyze CLso whole genome sequencing data from psyllids and plant hosts for variant calling only.



---



## Analysis Pipeline



The workflow used in this study:

# CLso Whole Genome Sequencing Analysis



Pipeline for analyzing **Candidatus Liberibacter solanacearum (CLso)** genomes associated with *Solanum umbelliferum* in California.



BioProject: PRJNA1399511



---



## Overview



This repository contains scripts used to process and analyze CLso whole genome sequencing data from psyllids and plant hosts.



---



## Analysis Pipeline



The workflow used in this study:


Raw Illumina reads
│
▼
Read trimming
│
▼
Quality control (FastQC / MultiQC)
│
▼
Mapping to reference genome (CLso ZC1) using BWA
│
▼
BAM processing using SAMtools
│
▼
Variant calling using GATK
│
▼
SNP matrix generation
│
▼
Haplotype analysis
│
▼
Phylogenetic tree reconstruction (MAFFT)



---



## Reference Genome



*Candidatus Liberibacter solanacearum* strain ZC1  

NCBI accession: **NC_014774.1**



---



## Data Availability



Raw sequencing reads and assemblies are available at:



BioProject: PRJNA1399511



---



## Scripts



All analysis scripts are located in the `scripts/` directory.



Scripts are numbered according to the order of the workflow.



---



## Author



Poulami Sarkar  

University of California Riverside
