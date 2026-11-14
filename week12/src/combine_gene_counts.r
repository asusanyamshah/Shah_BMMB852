# Combine per-sample featureCounts output (../week11/counts/<sample>.txt)
# into a single gene-level count matrix, with gene names pulled from the GTF.
#
# Input:
#   ../week11/design.csv            sample, group
#   ../week11/counts/<sample>.txt   featureCounts output (one column per sample)
#   ../week11/gtf/chr22.gtf         gene_id -> gene_name mapping
#
# Output:
#   results/gene_counts.csv         gene, name, <sample1>, <sample2>, ...

suppressMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
})

design <- read_csv("../week11/design.csv", show_col_types = FALSE)

counts_dir <- "../week11/counts"

read_one <- function(sample) {
  path <- file.path(counts_dir, paste0(sample, ".txt"))
  # featureCounts output: first line is a comment, second is the header
  df <- read.delim(path, comment.char = "#", stringsAsFactors = FALSE)
  # last column holds the counts; first column is Geneid
  data.frame(gene = df$Geneid, count = df[[ncol(df)]])
}

mat_list <- lapply(design$sample, function(s) {
  d <- read_one(s)
  names(d)[2] <- s
  d
})

gene_counts <- Reduce(function(x, y) full_join(x, y, by = "gene"), mat_list)
gene_counts <- gene_counts[, c("gene", design$sample)]

# ---- pull gene_id -> gene_name from the GTF ----
gtf_lines <- readLines("../week11/gtf/chr22.gtf")
gtf_lines <- gtf_lines[!startsWith(gtf_lines, "#")]

extract_attr <- function(attr_string, key) {
  m <- regmatches(attr_string, regexpr(paste0(key, ' "[^"]+"'), attr_string))
  sub(paste0(key, ' "([^"]+)"'), "\\1", m)
}

gene_lines <- gtf_lines[grepl("\tgene\t", gtf_lines)]
fields <- strsplit(gene_lines, "\t")
attrs  <- sapply(fields, function(f) f[9])

gene_id   <- sapply(attrs, extract_attr, key = "gene_id")
gene_name <- sapply(attrs, extract_attr, key = "gene_name")

gtf_map <- data.frame(gene = gene_id, name = gene_name, stringsAsFactors = FALSE)
gtf_map <- gtf_map[!duplicated(gtf_map$gene), ]

gene_counts <- gene_counts %>%
  left_join(gtf_map, by = "gene") %>%
  relocate(name, .after = gene)

dir.create("results", showWarnings = FALSE)
write_csv(gene_counts, "results/gene_counts.csv")

cat("Wrote results/gene_counts.csv with", nrow(gene_counts), "genes and",
    length(design$sample), "samples\n")
