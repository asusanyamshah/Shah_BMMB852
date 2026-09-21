# Week 04: Obtain FASTQ data from SRA

## How "popular" is this genome? How many datasets are available?
There are 4 datasets available for "Rotavirus J19"

## What is the breakdown by sequencing strategy and platform (or some other attribute)?
Every run uses Illumina Novaseq X

## What do you find interesting or surprising?
It was surprising how few rotavirus J19 sequences were available

## Steps taken for Makefile
The original Makefile was expanded to include an SRA read-processing workflow. The genome accession and reference sequence download commands were replaced with a parameterized SRA run accession (RUN) and read-count parameter (N). The new Makefile uses prefetch and fasterq-dump to obtain the sequencing reads, keeps the first N reads, and stores the raw FASTQ files in a raw directory. FastQC is then used to generate QC reports for the raw reads. The reads are processed with fastp to remove low-quality bases and adapters, with the trimmed reads stored in a separate trimmed directory. Finally, FastQC is run again on the trimmed reads so the raw and processed data can be compared. Completion marker files and variables for the run accession, number of reads, and number of threads were also added to make the workflow reproducible and easy to run with different SRA accessions.

## How to run
```pixi add sra-tools fastqc fastp```
```make```

## QC Results
Since the raw reads were already very high quality with a Phred score of 39, fastp didn't trim the reads, so the trimmed reads were the same quality as raw reads.