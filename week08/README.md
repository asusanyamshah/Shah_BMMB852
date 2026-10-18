# Week 08: Multi-sample variant calling and effect prediction

This workflow extends the E. coli analysis to three samples. It jointly calls haploid variants against the Week 05 reference, `NC_000913.3` (E. coli K-12 MG1655), then predicts coding consequences with `bcftools csq`.

## Samples and coverage

The three runs are from BioProject [PRJNA295606] and are reported by NCBI as E. coli B str. REL606:

| Run | Sample alias | Workflow |
| --- | --- | --- |
| `SRR2584863` | REL7179B | Reuses the aligned BAM from Week 05 |
| `SRR2584405` | REL965A | Downloads, subsamples, trims, and aligns |
| `SRR2584406` | REL11390 | Downloads, subsamples, trims, and aligns |

Depth: 
```
C = (N * L * 2) / G
C ≈ (155,000 * 150 * 2) / 4,640,000 ≈ 10x per sample
```

One thing to note is that he reads are from E. coli B REL606, whereas the reused Week 05 reference is E. coli K-12 MG1655. Calls can therefore represent fixed differences between strains, not just newly acquired variants.

## Requirements and run

Install `bcftools` using pixi. The reference FASTA and Week 05 BAM must already exist.
From this directory:
```
make clean
make
```
## coding variants

The variants below were pulled directly from the Week 08 multisample annotated VCF (`results/ecoli.multisample.annotated.vcf.gz`) using:

```sh
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/BCSQ[\t%GT]\n' \
    results/ecoli.multisample.annotated.vcf.gz | grep missense
```

All five are missense variants in the *thr* operon (`thrA`, `thrB`, `thrC`), and all are present (`GT=1`) in **all three samples** — consistent with these being fixed differences between the REL606-derived reads and the K-12 MG1655 reference, rather than mutations private to one lineage. 

| Position | Ref>Alt | Gene | Ref codon | Alt codon | Amino-acid change | GT (SRR2584863, SRR2584405, SRR2584406) |
| --- | --- | --- | --- | --- | --- | --- |
| 2108 | A>T | `thrA` | CAG | CTG | Q591L | 1, 1, 1 |
| 2116 | T>C | `thrA` | TAT | CAT | Y594H | 1, 1, 1 |
| 2597 | T>C | `thrA` | GTC | GCC | V754A | 1, 1, 1 |
| 3622 | A>T | `thrB` | GAA | GAT | E274D | 1, 1, 1 |
| 4442 | A>G | `thrC` | ACC | GCC | T237A | 1, 1, 1 |

## Interpreting the calls

As in Week 07, QUAL and mapping quality alone are not sufficient evidence that a coding-region variant is biologically real. For each annotated variant above, cross-check depth and allele balance in the sample's VCF record before treating a missense call as a confirmed amino-acid change, and keep the reference-strain caveat in mind: REL606-vs-K12 differences dominate this variant set, so most of what's annotated here is strain divergence, not evolved mutation.
