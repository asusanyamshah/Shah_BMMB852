# Summarize the gene-level count matrix: how many genes are unexpressed,
# how many are expressed, and a binned distribution of expression levels,
# averaged within each group defined in design.csv.
#
# Input:
#   results/gene_counts.csv   gene, name, <sample1>, <sample2>, ...
#   ../week11/design.csv      sample, group
#
# Output: printed to console (no file written)

suppressMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})

design <- read_csv("../week11/design.csv", show_col_types = FALSE)
gene_counts <- read_csv("results/gene_counts.csv", show_col_types = FALSE)

sample_cols <- design$sample

long <- gene_counts %>%
  select(gene, name, all_of(sample_cols)) %>%
  pivot_longer(cols = all_of(sample_cols), names_to = "sample", values_to = "count") %>%
  left_join(design, by = "sample")

group_avg <- long %>%
  group_by(gene, name, group) %>%
  summarise(mean_count = mean(count), .groups = "drop")

bin_expression <- function(x) {
  cut(x,
      breaks = c(-Inf, 0, 1, 10, 100, 1000, Inf),
      labels = c("0", "1-9", "10-99", "100-999", "1000-9999", "10000+"),
      right = FALSE)
}

group_avg <- group_avg %>%
  mutate(bin = bin_expression(mean_count))

cat("=== Overall ===\n")
n_total <- n_distinct(group_avg$gene)
cat("Total genes:", n_total, "\n\n")

for (g in unique(group_avg$group)) {
  sub <- group_avg %>% filter(group == g)
  n_zero <- sum(sub$mean_count == 0)
  n_expr <- sum(sub$mean_count > 0)
  cat("=== Group:", g, "===\n")
  cat("  Not expressed (mean count == 0):", n_zero, "\n")
  cat("  Expressed (mean count > 0):     ", n_expr, "\n")
  cat("  Expression level bins:\n")
  tab <- table(sub$bin)
  for (lvl in names(tab)) {
    cat(sprintf("    %-12s %d genes\n", lvl, tab[[lvl]]))
  }
  cat("\n")
}
