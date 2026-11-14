# Week 12: Transcript-level quantification + count matrices

This week reuses the chr22 RNA-seq data from week11 and adds a **transcript-level** quantification path with Salmon, alongside the existing **genome-level** quantification from featureCounts.

## How to run

Requires: `salmon`, R with the pckages: `tximport`, `dplyr`, `tidyr`, `readr` installed.

```sh
bioinfo
pixi add salmon
R -e 'BiocManager::install("tximport")'
```

This reuses week11's reference and read files
(`../week11/fasta/chr22.transcripts.fa`, `../week11/gtf/chr22.gtf`,
`../week11/fastq/`, `../week11/design.csv`, `../week11/counts/*.txt`)
Run week11's `make batch` first to generate the necessary data if you haven't.

From this directory:

```sh
make index   
make quant   
make all     
```

## Does the count matrix support the visually identified behavior?

Yes. In week11's IGV screenshots, UHR showed sharper, and more concentrated
expression (fewer genes, higher peaks) while HBR showed broader, more diffuse
expression (more genes, modest peaks). The count matrices confirm this based on the numbers that we see here:

| Group | Not expressed | Expressed | 1-9 | 10-99 | 100-999 | 1000-9999 | 10000+ |
|---|---|---|---|---|---|---|---|
| HBR | 737 | 634 | 865 | 194 | 200 | 109 | 3 |
| UHR | 601 | 770 | 810 | 228 | 181 | 147 | 5 |

UHR has *more* expressed genes overall (770 vs 634) but also more genes in
the highest bins (1000-9999: 147 vs 109; 10000+: 5 vs 3). 

LINC01399, as seen in week11 as UHR-specific (0 reads in all 3
HBR replicates, 2-3 reads in all 3 UHR replicates), is retained in both
count matrices built here, which is supporting the earlier visual nference.

## Genome-based vs. transcript-based gene counts

| | HBR | UHR |
|---|---|---|
| genes compared | 1,369 | 1,369 |
| mean abs error | 2.40 | 4.91 |
| median abs error | 0 | 0 |
| mean rel error | 0.23 | 0.30 |
| median rel error | 0 | 0 |

Most genes agree closely between the two quantification methods

| gene | name | group | genome | transcript | abs error | rel error |
|---|---|---|---|---|---|---|
| ENSG00000211677.2 | IGLC2 | UHR | 832.67 | 2678.49 | 1845.82 | 1.05 |
| ENSG00000100129.17 | EIF3L | UHR | 553.33 | 1005.56 | 452.23 | 0.58 |
| ENSG00000240972.1 | MIF | UHR | 54.00 | 468.22 | 414.22 | 1.59 |
| ENSG00000211679.2 | IGLC3 | UHR | 639.33 | 963.38 | 324.05 | 0.40 |
| ENSG00000241360.1 | PDXP | HBR | 3.33 | 242.19 | 238.85 | 1.95 |
| ENSG00000100014.19 | SPECC1L | HBR | 71.33 | 292.06 | 220.72 | 1.21 |
| ENSG00000211666.2 | IGLV2-14 | UHR | 15.67 | 183.33 | 167.67 | 1.69 |

Several of the largest discrepancies (IGLC2, IGLC3, IGLV2-14) are
immunoglobulin-locus genes, which are known to have many near-identical
paralogs and transcript isoforms. Genome alignment (featureCounts) and
transcriptome pseudoalignment (Salmon's EM-based ambiguous-read allocation)
handle multi-mapping reads at these loci very differently, which potentially
explains the large gap. 

## AI prompting experience

AI prompting experience has been fairly decent. Claude used a lot of tokens, but gave straightforward and accurate answers/explanations. Github copilot seemed to hallucinate a lot more. Claude handled large context windows well and was able to inspect images and explain the results well and accurately. 

