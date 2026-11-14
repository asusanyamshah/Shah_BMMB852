# Summarize transcript-level counts (results/transcript_counts.csv) up to
# gene-level counts by summing all transcripts belonging to the same gene.
# This gives a gene-level matrix derived from transcript (Salmon) data, which
# can be compared against the genome-based (featureCounts) gene matrix.
#
# Input:
#   results/transcript_counts.csv   transcript, gene, name, <sample1>, ...
#
# Output:
#   results/transcripts_as_genes.csv   gene, name, <sample1>, ...

suppressMessages({
  library(dplyr)
  library(readr)
})

tx <- read_csv("results/transcript_counts.csv", show_col_types = FALSE)

sample_cols <- setdiff(colnames(tx), c("transcript", "gene", "name"))

gene_counts <- tx %>%
  group_by(gene, name) %>%
  summarise(across(all_of(sample_cols), sum), .groups = "drop")

dir.create("results", showWarnings = FALSE)
write_csv(gene_counts, "results/transcripts_as_genes.csv")

cat("Wrote results/transcripts_as_genes.csv with", nrow(gene_counts),
    "genes and", length(sample_cols), "samples\n")
