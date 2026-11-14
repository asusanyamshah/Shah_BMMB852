# Compare genome-based gene counts (featureCounts) against transcript-based
# gene counts (Salmon + tximport, summed to gene level), per group average.
#
# Input:
#   results/gene_counts.csv          genome-based gene counts
#   results/transcripts_as_genes.csv transcript-summed-to-gene counts
#   ../week11/design.csv             sample, group
#
# Output:
#   results/count_comparison.csv     gene, name, group, genome, transcript,
#                                     abs_error, rel_error
#   printed summary + top mismatches

suppressMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})

design <- read_csv("../week11/design.csv", show_col_types = FALSE)

genome_counts     <- read_csv("results/gene_counts.csv", show_col_types = FALSE)
transcript_counts <- read_csv("results/transcripts_as_genes.csv", show_col_types = FALSE)

to_long_group_avg <- function(df, value_name) {
  df %>%
    select(gene, name, all_of(design$sample)) %>%
    pivot_longer(cols = all_of(design$sample), names_to = "sample", values_to = "count") %>%
    left_join(design, by = "sample") %>%
    group_by(gene, name, group) %>%
    summarise(mean_count = mean(count), .groups = "drop") %>%
    rename(!!value_name := mean_count)
}

genome_long     <- to_long_group_avg(genome_counts, "genome")
transcript_long <- to_long_group_avg(transcript_counts, "transcript")

merged <- inner_join(genome_long, transcript_long, by = c("gene", "name", "group")) %>%
  mutate(
    abs_error = abs(genome - transcript),
    rel_error = ifelse(genome == 0 & transcript == 0, 0,
                        abs_error / ((genome + transcript) / 2))
  )

dir.create("results", showWarnings = FALSE)
write_csv(merged, "results/count_comparison.csv")

cat("# abs error = |genome - transcript|\n")
cat("# rel error = abs error / mean(genome, transcript); 0 when both are 0\n\n")

summary_tab <- merged %>%
  group_by(group) %>%
  summarise(
    genes = n(),
    mean_abs_error = mean(abs_error),
    median_abs_error = median(abs_error),
    mean_rel_error = mean(rel_error),
    median_rel_error = median(rel_error)
  )

print(as.data.frame(summary_tab), row.names = FALSE)

cat("\n# Most dissimilar expression levels\n")
top <- merged %>% arrange(desc(abs_error)) %>% head(8)
print(as.data.frame(top), row.names = FALSE)
